require 'rails_helper'

describe PaypalSubscriptionsService, type: :service do
  before :each do
    allow_any_instance_of(SubscriptionPlanService).to receive(:queue_async)
  end
  let(:user) { create(:student_user) }
  let(:subscription) { create(:subscription, user: user) }
  subject { PaypalSubscriptionsService.new(subscription) }

  # INSTANCE METHODS ###########################################################

  describe '#execute_billing_agreement' do
    let(:agreement_dbl) {
      double(
        'Agreement',
        id: 'I-ERW92H1T8T1ST',
        state: 'Active'
      )
    }

    it 'must have a subscription' do
      expect { subject.execute_billing_agreement }.to raise_error ArgumentError
    end

    it 'must have a token' do
      expect { subject.execute_billing_agreement }.to raise_error ArgumentError
      expect { subject.execute_billing_agreement('token') }.not_to raise_error ArgumentError
    end

    it 'calls EXECUTE on an instance of PayPal Agreement' do
      expect_any_instance_of(PayPal::SDK::REST::DataTypes::Agreement).to receive(:execute).and_return(true)
      expect_any_instance_of(PayPal::SDK::REST::DataTypes::Agreement).to receive(:token=)

      subject.execute_billing_agreement('token')
    end

    it 'accurately updates the subscription' do
      allow_any_instance_of(PayPal::SDK::REST::DataTypes::Agreement).to receive(:execute).and_return(true)
      allow_any_instance_of(PayPal::SDK::REST::DataTypes::Agreement).to receive(:state).and_return('Active')
      allow_any_instance_of(PayPal::SDK::REST::DataTypes::Agreement).to receive(:id).and_return('AGREEMENT_ID')

      expect {
        subject.execute_billing_agreement('dummy_token')
      }.to change { subscription.paypal_status }.from(nil).to('Active')
       .and change { subscription.paypal_subscription_guid }.from(nil).to('AGREEMENT_ID')
    end
  end

  describe '#un_cancel' do
    let(:pending_agreement_dbl) {
      double(
        'Agreement',
        token: 'tok_FDAF343DFDA',
        links: [double( rel: 'approval_url', href: 'https://example.com/approval' )],
        state: 'Pending'
      )
    }

    let(:suspended_agreement_dbl) {
      double(
        'Agreement',
        token: 'tok_FDAF343DFDA',
        links: [double( rel: 'approval_url', href: 'https://example.com/approval' )],
        state: 'Suspended'
      )
    }

    it 'raises an error unless the associated Billing Agreement is SUSPENDED' do
      allow(PayPal::SDK::REST::DataTypes::Agreement).to receive(:find).and_return(pending_agreement_dbl)

      expect { subject.un_cancel }.to raise_error(Learnsignal::SubscriptionError)
    end

    it 'calls #re_activate on the Agreement' do
      allow(PayPal::SDK::REST::DataTypes::Agreement).to receive(:find).and_return(suspended_agreement_dbl)
      expect(suspended_agreement_dbl).to receive(:re_activate).and_return(true)

      subject.un_cancel
    end

    it 'raises an error if #re_activate fails' do
      allow(PayPal::SDK::REST::DataTypes::Agreement).to receive(:find).and_return(suspended_agreement_dbl)
      allow(suspended_agreement_dbl).to receive(:re_activate).and_return(false)

      expect { subject.un_cancel }.to raise_error(Learnsignal::SubscriptionError)
    end

    it 'updates the subscription if #re_activate succeeds' do
      allow(PayPal::SDK::REST::DataTypes::Agreement).to receive(:find).and_return(suspended_agreement_dbl)
      allow(suspended_agreement_dbl).to receive(:re_activate).and_return(true)
      expect(subscription).to receive(:update!)
      expect(subscription).to receive(:restart)

      subject.un_cancel
    end
  end

  describe '#create_and_return_subscription' do
    let(:agreement_dbl) {
      double(
        'Agreement',
        token: 'tok_FDAF343DFDA',
        links: [double( rel: 'approval_url', href: 'https://example.com/approval' )],
        state: 'Pending'
      )
    }

    it 'calls the #create_billing_agreement method' do
      expect(subject).to receive(:create_billing_agreement).and_return(agreement_dbl)

      subject.create_and_return_subscription
    end

    it 'returns an updated subscription object with the PayPal attributes' do
      allow(subject).to receive(:create_billing_agreement).and_return(agreement_dbl)
      expect(subscription.paypal_token).to be_nil
      expect(subscription.paypal_approval_url).to be_nil
      expect(subscription.paypal_status).to be_nil

      subject.create_and_return_subscription

      expect(subscription.paypal_token).not_to be_nil
      expect(subscription.paypal_approval_url).not_to be_nil
      expect(subscription.paypal_status).not_to be_nil
    end
  end

  describe '#create_billing_agreement' do
    it 'calls CREATE on an instance of PayPal Agreement' do
      expect_any_instance_of(PayPal::SDK::REST::DataTypes::Agreement).to receive(:create).and_return(true)

      subject.send(:create_billing_agreement, subscription: subscription)
    end
  end

  describe '#cancel_billing_agreement' do
    before :each do
      @dbl = double
      allow(@dbl).to receive(:state).and_return('Active')
    end

    it 'calls FIND on an instance of PayPal::SDK::REST::DataTypes::Agreement::Plan' do
      expect(PayPal::SDK::REST::DataTypes::Agreement).to receive(:find).and_return(@dbl)
      allow(@dbl).to receive(:suspend).and_return(true)

      subject.cancel_billing_agreement
    end

    it 'calls SUSPEND on an instance of PayPal::SDK::REST::DataTypes::Agreement::Plan' do
      expect(@dbl).to receive(:suspend).and_return(true)
      allow(PayPal::SDK::REST::DataTypes::Agreement).to receive(:find).and_return(@dbl)

      subject.cancel_billing_agreement
    end

    it 'updates the state of the subscription to PENDING_CANCELLATION' do
      allow(PayPal::SDK::REST::DataTypes::Agreement).to receive(:find).and_return(@dbl)
      allow(@dbl).to receive(:suspend).and_return(true)
      new_subscription = create(:subscription, state: 'active')

      PaypalSubscriptionsService.new(new_subscription).cancel_billing_agreement

      new_subscription.reload
      expect(new_subscription.state).to eq 'pending_cancellation'
    end
  end

  describe '#cancel_billing_agreement_immediately' do
    before :each do
      @dbl = double
      allow(@dbl).to receive(:state).and_return('Active')
    end

    it 'calls FIND on an instance of PayPal::SDK::REST::DataTypes::Agreement::Plan' do
      expect(PayPal::SDK::REST::DataTypes::Agreement).to receive(:find).and_return(@dbl)
      allow(@dbl).to receive(:cancel).and_return(true)

      subject.cancel_billing_agreement_immediately
    end

    describe 'for subscriptions already cancelled on PayPal' do
      it 'calls CANCEL on the subscription' do
        @cancelled_dbl = double(state: 'Cancelled')
        allow(PayPal::SDK::REST::DataTypes::Agreement).to receive(:find).and_return(@cancelled_dbl)
        new_subscription = create(:subscription, state: 'active')
        expect(new_subscription).to receive(:cancel)

        PaypalSubscriptionsService.new(new_subscription).cancel_billing_agreement_immediately
      end
    end

    describe 'for uncancelled subscriptions' do
      it 'calls CANCEL on an instance of PayPal::SDK::REST::DataTypes::Agreement::Plan' do
        expect(@dbl).to receive(:cancel).and_return(true)
        allow(PayPal::SDK::REST::DataTypes::Agreement).to receive(:find).and_return(@dbl)

        subject.cancel_billing_agreement_immediately
      end

      it 'updates the state of the subscription to CANCELLED' do
        allow(PayPal::SDK::REST::DataTypes::Agreement).to receive(:find).and_return(@dbl)
        allow(@dbl).to receive(:cancel).and_return(true)
        new_subscription = create(:subscription, state: 'active')

        PaypalSubscriptionsService.new(new_subscription).cancel_billing_agreement_immediately

        new_subscription.reload
        expect(new_subscription.state).to eq 'cancelled'
      end
    end
  end

  describe '#update_next_billing_date' do
    let(:billing_date) { Time.zone.now + 1.week }
    let(:agreement_dbl) {
      double(
        'Agreement',
        agreement_details: double(next_billing_date: billing_date)
      )
    }

    let(:new_subscription) { create(:subscription, paypal_subscription_guid: 'test_guid') }
    let(:new_subject) { PaypalSubscriptionsService.new(new_subscription) }

    it 'returns NIL unless there is a paypal_subscription_guid' do
      expect(subject.update_next_billing_date).to be_nil
    end

    it 'updates the subscription' do
      allow(PayPal::SDK::REST::DataTypes::Agreement).to receive(:find).and_return(agreement_dbl)
      expect(new_subscription).to receive(:update!).with(
        next_renewal_date: billing_date
      ).and_return(true)

      new_subject.update_next_billing_date
    end
  end

  describe '#set_cancellation_date' do
    let(:billing_date) { Time.zone.now + 1.week }
    let(:agreement_dbl) {
      double(
        'Agreement',
        state: 'Suspended',
        agreement_details: double(last_payment_date: billing_date)
      )
    }
    let(:new_subscription) { create(:subscription, paypal_subscription_guid: 'test_guid') }
    let(:new_subject) { PaypalSubscriptionsService.new(new_subscription) }

    before :each do
      allow(PayPal::SDK::REST::DataTypes::Agreement).to receive(:find).and_return(agreement_dbl)
    end

    it 'updates the subscription with the Agreement state' do
      expect(new_subscription).to receive(:update).with(paypal_status: 'Suspended')

      new_subject.set_cancellation_date
    end

    it 'calls the PaypalSubscriptionCancellationWorker' do
      expect(PaypalSubscriptionCancellationWorker).to receive(:perform_at)

      new_subject.set_cancellation_date
    end
  end

  describe '#change_plan' do
    let(:target_date) { 1.week.from_now.iso8601 }

    before :each do
      @dbl = double(state: 'Active', agreement_details: double(next_billing_date: target_date))
    end

    it 'calls FIND on an instance of PayPal::SDK::REST::DataTypes::Agreement' do
      expect(PayPal::SDK::REST::DataTypes::Agreement).to receive(:find).and_return(@dbl)
      allow(subject).to receive(:create_new_subscription).and_return(true)
      allow(subject).to receive(:cancel_billing_agreement)

      subject.change_plan('plan-id-12345')
    end

    it 'creates a new subscription with the new plan_id' do
      allow(PayPal::SDK::REST::DataTypes::Agreement).to receive(:find).and_return(@dbl)
      allow(subject).to receive(:cancel_billing_agreement)
      expect(subject).to receive(:create_new_subscription).with('plan-id-12345', Time.parse(target_date).iso8601).and_return(true)

      subject.change_plan('plan-id-12345')
    end
  end

  describe '#create_new_subscription' do
    let(:agreement_dbl) {
      double(
        'Agreement',
        token: 'tok_FDAF343DFDA',
        links: [double( rel: 'approval_url', href: 'https://example.com/approval' )],
        state: 'Pending'
      )
    }
    let(:plan) { create(:subscription_plan, paypal_guid: 'plan-id-12345', currency: subscription.subscription_plan.currency) }

    it 'creates a new Learnsignal subscription' do
      allow(subject).to receive(:create_billing_agreement).and_return(agreement_dbl)

      expect { subject.create_new_subscription(plan.id, nil) }.to change { Subscription.count }.from(1).to(2)
    end
  end

  # PRIVATE METHODS ############################################################

  describe '#agreement_attributes' do
    it 'returns the correct hash when there is no start date' do
      expect(subject.send(:agreement_attributes, subscription: subscription))
        .to eq (
          {
            name: subscription.subscription_plan.name,
            description: subscription.subscription_plan.description.gsub("\n", ""),
            start_date: (Time.zone.now + subscription.subscription_plan.payment_frequency_in_months.months).iso8601,
            payer: {
              payment_method: "paypal",
              payer_info: {
                email: subscription.user.email,
                first_name: subscription.user.first_name,
                last_name: subscription.user.last_name
              }
            },
            override_merchant_preferences: {
              setup_fee: {
                value: subscription.subscription_plan.price.to_s,
                currency: subscription.subscription_plan.currency.iso_code
              },
              return_url: "https://staging.learnsignal.com/en/subscriptions/#{subscription.id}/execute?payment_processor=paypal",
              cancel_url: "https://staging.learnsignal.com/en/subscriptions/new?flash=It+seems+you+cancelled+your+subscription+on+Paypal.+Still+want+to+upgrade%3F"
            },
            plan: {
              id: subscription.subscription_plan.paypal_guid
            }
          }
        )
    end

    it 'returns the correct hash when there is a start date (no setup fee)' do
      new_time = Time.zone.now + 1.week
      expect(subject.send(:agreement_attributes, subscription: subscription, start_date: new_time)).
        to eq(
          name: subscription.subscription_plan.name,
          description: subscription.subscription_plan.description.delete("\n"),
          start_date: new_time.iso8601,
          payer: {
            payment_method: 'paypal',
            payer_info: {
              email: subscription.user.email,
              first_name: subscription.user.first_name,
              last_name: subscription.user.last_name
            }
          },
          override_merchant_preferences: {
            setup_fee: {},
            return_url: "https://staging.learnsignal.com/en/subscriptions/#{subscription.id}/execute?payment_processor=paypal",
            cancel_url: 'https://staging.learnsignal.com/en/subscriptions/new?flash=It+seems+you+cancelled+your+subscription+on+Paypal.+Still+want+to+upgrade%3F'
          },
          plan: {
            id: subscription.subscription_plan.paypal_guid
          }
        )
    end
  end

  describe '#subscription_setup_fee' do
    it 'returns an empty hash if a start_date is passed in' do
      expect(subject.send(:subscription_setup_fee, Time.zone.tomorrow, subscription.subscription_plan)).to eq ({})
    end

    it 'returns the correct hash if no start_date is passed in' do
      expect(
        subject.send(:subscription_setup_fee, nil, subscription.subscription_plan)
      ).to eq(currency: subscription.subscription_plan.currency.iso_code, value: subscription.subscription_plan.price.to_s)
    end
  end

  describe '#raise_subscription_error' do
    it 'logs the error and raises' do
      expect(Rails.logger).to receive(:error)

      expect{ subject.send(:raise_subscription_error, {}, 'test_method', :generic) }.to raise_error(Learnsignal::SubscriptionError)
    end
  end

  describe '#return_message' do
    it 'returns a default string message' do
      expect(subject.send(:return_message, :generic)).to be_kind_of String
    end
  end
end
