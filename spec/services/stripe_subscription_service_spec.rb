# frozen_string_literal: true

require 'rails_helper'

describe StripeSubscriptionService, type: :service do
  let(:subscription) { build_stubbed(:stripe_subscription) }
  subject { StripeSubscriptionService.new(subscription) }

  before :each do
    allow_any_instance_of(SubscriptionPlanService).to receive(:queue_async)
  end

  describe '#retrieve_subscription' do
    it 'calls the retrieve method on Stripe::Subscriptions' do
      expect(Stripe::Subscription).to receive(:retrieve).with(id: subscription.stripe_guid)

      subject.retrieve_subscription
    end
  end

  describe '#change_plan' do
    let(:sub_plan) { create(:subscription_plan) }
    let(:new_sub) { create(:subscription, subscription_plan_id: sub_plan.id) }
    let(:stripe_sub) {
      double(
        latest_invoice: { payment_intent: { client_secret: 'cs_123456' }},
        status: 'active'
      )
    }

    it 'calls #create_subscription' do
      allow(subject).to receive(:update_old_subscription)
      expect(subject).to receive(:create_subscription).
                           and_return([new_sub, stripe_sub])

      subject.change_plan(sub_plan.id)
    end

    it 'starts the new subscription' do
      allow(subject).to receive(:create_subscription).
                          and_return([new_sub, stripe_sub])
      allow(subject).to receive(:update_old_subscription)
      expect_any_instance_of(Subscription).to receive(:start)

      subject.change_plan(sub_plan.id)
    end

    it 'calls #update_old_subscription' do
      allow(subject).to receive(:create_subscription).
                          and_return([new_sub, stripe_sub])
      expect(subject).to receive(:update_old_subscription)

      subject.change_plan(sub_plan.id)
    end

    it 'returns a subscription and stripe object' do
      allow(subject).to receive(:create_subscription).
                          and_return([new_sub, stripe_sub])
      allow(subject).to receive(:update_old_subscription)

      expect(subject.change_plan(sub_plan.id)).to be_kind_of Array
    end

    describe 'for payments failing 3DS' do
      let(:stripe_sub_3ds) {
        double(
          latest_invoice: { payment_intent: { client_secret: 'cs_123456' }},
          status: 'past_due'
        )
      }

      it 'calls #mark_payment_action_required on the subscription' do
        allow(subject).to receive(:create_subscription).
                          and_return([new_sub, stripe_sub_3ds])
        allow(subject).to receive(:update_old_subscription)
        expect_any_instance_of(Subscription).to receive(:mark_payment_action_required)

        subject.change_plan(sub_plan.id)
      end
    end
  end

  describe '#create_and_return_subscription' do
    let(:new_sub) { build(:subscription) }
    let(:stripe_customer) { double(id: 'cus_12345') }
    let(:stripe_sub) {
      JSON.parse(
        File.read(
          Rails.root.join('spec/fixtures/stripe/create_sub_with_payment_intent.json')
        ), object_class: OpenStruct
      )
    }

    it 'updates the customer on Stripe' do
      allow(subject).to receive(:create_stripe_subscription).and_return(stripe_sub)
      allow(subject).to receive(:merge_subscription_data).and_return(new_sub)
      expect(Stripe::Customer).to receive(:update).and_return(stripe_customer)

      subject.create_and_return_subscription('sk_test_token', nil)
    end

    it 'calls #create_stripe_subscription' do
      allow(Stripe::Customer).to receive(:update).and_return(stripe_customer)
      allow(subject).to receive(:merge_subscription_data).and_return(new_sub)
      expect(subject).to receive(:create_stripe_subscription).and_return(stripe_sub)

      subject.create_and_return_subscription('sk_test_token', nil)
    end

    it 'calls #merge_subscription_data' do
      allow(Stripe::Customer).to receive(:update).and_return(stripe_customer)
      allow(subject).to receive(:create_stripe_subscription).and_return(stripe_sub)
      expect(subject).to receive(:merge_subscription_data).and_return(new_sub)

      subject.create_and_return_subscription('sk_test_token', nil)
    end

    it 'returns the correct data' do
      allow(Stripe::Customer).to receive(:update).and_return(stripe_customer)
      allow(subject).to receive(:create_stripe_subscription).and_return(stripe_sub)
      allow(subject).to receive(:merge_subscription_data).and_return(new_sub)

      expect(subject.create_and_return_subscription('sk_test_token', nil)).to(
        include(
          a_kind_of(Subscription),
          { status: :ok }
        )
      )
    end

    describe 'with Stripe errors' do
      describe 'Stripe::CardError' do
        let(:card_error) {
          Stripe::InvalidRequestError.new(
            'error message', 'param', json_body: {error: {type: 'card_error' }}
          )
        }

        it 'raises a subscription error with the correct message' do
          allow(Stripe::Customer).to receive(:update).and_return(stripe_customer)
          allow(subject).to receive(:create_stripe_subscription).and_raise(card_error)

          expect{
            subject.create_and_return_subscription('sk_test_token', nil)
          }.to raise_error(Learnsignal::SubscriptionError)
        end
      end

      describe 'Stripe::InvalidRequestError' do
        let(:invalid_error) {
          Stripe::InvalidRequestError.new(
            'error message', 'param', json_body: {error: {type: 'invalid_request' }}
          )
        }

        it 'raises a subscription error with the correct message' do
          allow(Stripe::Customer).to receive(:update).and_raise(invalid_error)

          expect{
            subject.create_and_return_subscription('sk_test_token', nil)
          }.to raise_error(Learnsignal::SubscriptionError)
        end
      end
    end
  end

  describe '#cancel_subscription' do
    let(:test_sub) { create(:stripe_subscription, state: 'active') }
    subject{ StripeSubscriptionService.new(test_sub) }

    it 'raises an error if no customer is present on the subscription' do
      test_sub.stripe_customer_id = nil
      expect{ subject.cancel_subscription }.to raise_error Learnsignal::SubscriptionError
    end

    it 'railse an error if the subscription does not have a stripe_guid' do
      test_sub.stripe_guid = nil
      expect{ subject.cancel_subscription }.to raise_error Learnsignal::SubscriptionError
    end

    describe 'when immediately is set to false' do
      let(:stripe_sub) { double(status: 'active') }

      it 'calls #cancel_stripe_subscription with period_end == true' do
        expect(subject).to(
          receive(:cancel_stripe_subscription).with(period_end: true)
        ).and_return(stripe_sub)

        subject.cancel_subscription(immediately: false)
      end

      it 'sets the subscription to pending_cancellation' do
        allow(subject).to receive(:cancel_stripe_subscription).and_return(stripe_sub)

        expect{ subject.cancel_subscription(immediately: false) }.to change {
          test_sub.state
        }.from('active').to('pending_cancellation')
      end

      it 'updates the subscription with the correct stripe_status' do
        allow(subject).to receive(:cancel_stripe_subscription).and_return(stripe_sub)

        expect{ subject.cancel_subscription(immediately: true) }.not_to change {
          test_sub.stripe_status
        }
      end
    end

    describe 'when immediately is set to true' do
      let(:stripe_sub) { double(status: 'canceled') }

      it 'calls #cancel_stripe_subscription with period_end == false' do
        expect(subject).to(
          receive(:cancel_stripe_subscription).with(period_end: false)
        ).and_return(stripe_sub)

        subject.cancel_subscription(immediately: true)
      end

      it 'sets the subscription to cancelled' do
        allow(subject).to receive(:cancel_stripe_subscription).and_return(stripe_sub)

        expect{ subject.cancel_subscription(immediately: true) }.to change {
          test_sub.state
        }.from('active').to('cancelled')
      end

      it 'updates the subscription with the correct stripe_status' do
        allow(subject).to receive(:cancel_stripe_subscription).and_return(stripe_sub)

        expect{ subject.cancel_subscription(immediately: true) }.to change {
          test_sub.stripe_status
        }.from('active').to('canceled')
      end
    end
  end

  # PRIVATE METHODS ============================================================

  describe '#cancel_stripe_subscription' do
    let(:stripe_sub) { double(status: 'canceled') }

    before :each do
      allow(subject).to receive(:retrieve_subscription).and_return(stripe_sub)
    end

    describe 'for period_end == true' do
      it 'schedules the subscription for cancelation' do
        expect(stripe_sub).to receive(:cancel_at_period_end=)
        expect(stripe_sub).to receive(:save)

        subject.send(:cancel_stripe_subscription, period_end: true)
      end
    end

    describe 'for period_end == false' do
      it 'cancels the subscription immediately' do
        expect(stripe_sub).to receive(:delete)

        subject.send(:cancel_stripe_subscription, period_end: false)
      end
    end
  end

  describe '#create_subscription' do
    let(:user) { create(:student_user) }
    let(:test_sub) { create(:stripe_subscription, user: user, state: 'active') }
    let(:sub_plan) { create(:subscription_plan, currency: test_sub.currency) }
    let(:stripe_sub) {
      JSON.parse(
        File.read(
          Rails.root.join('spec/fixtures/stripe/create_sub_with_payment_intent.json')
        ), object_class: OpenStruct
      )
    }

    subject{ StripeSubscriptionService.new(test_sub) }

    before :each do
      create(:subscription_payment_card, user: user)
    end

    it 'calls #get_updated_stripe_subscription' do
      expect(subject).to receive(:get_updated_stripe_subscription).and_return(stripe_sub)

      subject.send(:create_subscription, sub_plan)
    end

    it 'creates a new Subscription record' do
      allow(subject).to receive(:get_updated_stripe_subscription).and_return(stripe_sub)

      expect{ subject.send(:create_subscription, sub_plan) }.to(
        change { Subscription.count }.from(1).to(2)
      )
    end
  end

  describe '#create_stripe_subscription' do
    it 'creates a Stripe Subscription' do
      expect(Stripe::Subscription).to(
        receive(:create).with(
          hash_including(expand: ['latest_invoice.payment_intent'])
        )
      )

      subject.send(:create_stripe_subscription, 'cus_12345', nil)
    end
  end

  describe '#get_updated_stripe_subscription' do
    let(:test_sub) { create(:stripe_subscription) }
    let(:sub_plan) { create(:subscription_plan, currency: test_sub.currency) }
    let(:stripe_sub) { double(items: [OpenStruct.new(id: 'si_test_12345')]) }

    it 'retrieves a Stripe Subscription' do
      expect(Stripe::Subscription).to receive(:retrieve).and_return(stripe_sub)
      allow(Stripe::Subscription).to receive(:update)

      subject.send(:get_updated_stripe_subscription, sub_plan)
    end

    it 'updates the Stripe Subscription' do
      allow(Stripe::Subscription).to receive(:retrieve).and_return(stripe_sub)
      expect(Stripe::Subscription).to receive(:update)

      subject.send(:get_updated_stripe_subscription, sub_plan)
    end
  end

  describe '#merge_subscription_data' do
    let(:customer) { double(id: 'cus_123456', to_hash: {}) }
    let(:test_sub) { create(:stripe_subscription, state: 'active') }
    let(:sub_plan) { create(:subscription_plan, currency: test_sub.currency) }
    let(:stripe_sub) {
      JSON.parse(
        File.read(
          Rails.root.join('spec/fixtures/stripe/create_sub_with_payment_intent.json')
        ), object_class: OpenStruct
      )
    }

    subject{ StripeSubscriptionService.new(test_sub) }

    it 'assigns attributes to the subscription' do
      expect(test_sub).to receive(:assign_attributes)

      subject.send(:merge_subscription_data, stripe_sub, customer)
    end
  end

  describe '#renewal_date' do
    before do
      Timecop.freeze(Time.zone.local(2019, 8, 19, 11, 05, 0))
    end

    it 'transforms a timestamp into a timezone object' do
      stripe_sub = double(current_period_end: 1566209100)
      expect(subject.send(:renewal_date, stripe_sub)).to eq Time.zone.now
    end
  end

  describe '#update_old_subscription' do
    let(:sub_plan) { create(:subscription_plan) }
    let(:real_sub) { create(:subscription) }
    let(:new_sub) { create(:subscription, subscription_plan_id: sub_plan.id) }

    subject { StripeSubscriptionService.new(real_sub) }

    before :each do
      create(:student_access, user: real_sub.user)
    end

    it "updates the user's student_access" do
      expect(real_sub.user.student_access).to receive(:update)

      subject.send(:update_old_subscription, new_sub)
    end

    it 'updates the subscription to be cancelled' do
      subject.send(:update_old_subscription, new_sub)

      expect(real_sub.stripe_status).to eq 'canceled'
      expect(real_sub.state).to eq 'cancelled'
    end
  end
end
