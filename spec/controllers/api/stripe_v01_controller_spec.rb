require 'rails_helper'

describe Api::StripeV01Controller, type: :controller do

  let!(:start_stripe_mock) { StripeMock.start }
  let(:stripe_helper) { StripeMock.create_test_helper }

  let!(:usd) { FactoryGirl.create(:usd) }
  let!(:student) { FactoryGirl.create(:individual_student_user) }
  let!(:referred_student) { FactoryGirl.create(:individual_student_user) }
  let!(:referral_code) { FactoryGirl.create(:referral_code, user_id: student.id) }
  let!(:subscription_plan_m) { FactoryGirl.create(:student_subscription_plan_m) }
  let!(:subscription_plan_q) { FactoryGirl.create(:student_subscription_plan_q) }
  let!(:subscription_plan_y) { FactoryGirl.create(:student_subscription_plan_y) }
  let!(:card_details_1) { {number: '4242424242424242', cvc: '123', exp_month: '12', exp_year: '2019'} }
  let!(:card_details_2) { {number: '4242424242424242', cvc: '123', exp_month: '11', exp_year: '2019'} }
  let!(:card_token_1)   { Stripe::Token.create(card: card_details_1) }
  let!(:card_token_2)   { Stripe::Token.create(card: card_details_2) }
  let!(:subscription_1) { FactoryGirl.create(:subscription, user_id: student.id,
                          subscription_plan_id: subscription_plan_m.id,
                          stripe_token: card_token_1.id) }
  let!(:subscription_2) { FactoryGirl.create(:subscription, user_id: referred_student.id,
                                             subscription_plan_id: subscription_plan_m.id,
                                             current_status: 'trialing',
                                             stripe_token: card_token_2.id) }
  let!(:referred_signup) { FactoryGirl.create(:referred_signup,
                                              referral_code_id: referral_code.id,
                                              subscription_id: subscription_2.id) }

  let!(:invoice_created_event) {
    StripeMock.mock_webhook_event('invoice.created',
                                  subscription: subscription_1.stripe_guid,
                                  customer: student.stripe_customer_id) }
  let!(:invoice_updated) { StripeMock.mock_webhook_event('invoice.updated') }
  let!(:customer_subscription_updated_event) { StripeMock.mock_webhook_event("customer.subscription.updated") }

  describe "POST 'create'" do
    describe 'preliminary functionality: ' do
      it 'returns 204 when called with no payload' do
        post :create
        expect(response.status).to eq(204)
      end

      it 'logs an error if invalid JSON is received' do
        expect(Rails.logger).to receive(:error)
        post :create, event: {id: '123'}
        expect(response.status).to eq(404)
      end
    end

    describe 'dealing with payload data:' do
      describe 'invoice' do
        before(:each) do
          SubscriptionPlan.skip_callback(:update, :before, :update_on_stripe_platform)
          subscription_plan_m.stripe_guid = invoice_created_event.data.object.lines.data[0].plan.id
          subscription_plan_m.save
          subscription_1.update_attribute(:stripe_guid, invoice_created_event.data.object.subscription)
        end

        it 'created' do
          post :create, invoice_created_event.to_json
          expect(StripeApiEvent.count).to eq(1)
          expect(Invoice.count).to eq(1)
          expect(InvoiceLineItem.count).to eq(invoice_created_event.data.object.lines.data.length)
        end

        xit 'payment_failed' do
          # We have to test here whether mail 'Subscription Error' has been sent over Mandrill
        end
      end

      describe 'customer.subscription' do
        before(:each) do
          subscription_2.update_attribute(:stripe_guid, customer_subscription_updated_event.data.object.id)
        end

        it 'updated' do
          post :create, customer_subscription_updated_event.to_json
          expect(subscription_2.reload.current_status).to eq('active')
          expect((40.days.from_now - referred_signup.reload.maturing_on).to_i.abs).to be < 1.day.seconds
          # We have to test here whether mail 'Trial Converted' has been sent over Mandrill
        end
      end
    end

  end

end
