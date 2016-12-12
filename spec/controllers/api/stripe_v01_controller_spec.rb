require 'rails_helper'
require 'mandrill_client'
require 'support/users_and_groups_setup'

describe Api::StripeV01Controller, type: :controller do

  include_context 'users_and_groups_setup'

  let!(:start_stripe_mock) { StripeMock.start }
  let(:stripe_helper) { StripeMock.create_test_helper }

  let!(:usd) { FactoryGirl.create(:usd) }
  let!(:student) { FactoryGirl.create(:individual_student_user, student_user_type_id: subscription_user_type.id) }
  let!(:referred_student) { FactoryGirl.create(:individual_student_user) }
  let!(:referral_code) { FactoryGirl.create(:referral_code, user_id: student.id) }
  let!(:subscription_plan_m) { FactoryGirl.create(:student_subscription_plan_m) }
  let!(:subscription_plan_q) { FactoryGirl.create(:student_subscription_plan_q) }
  let!(:card_details_1) { {number: '4242424242424242', cvc: '123', exp_month: '12', exp_year: '2019'} }
  let!(:card_details_2) { {number: '4242424242424242', cvc: '123', exp_month: '11', exp_year: '2019'} }
  let!(:card_token_1)   { Stripe::Token.create(card: card_details_1) }
  let!(:card_token_2)   { Stripe::Token.create(card: card_details_2) }
  let!(:subscription_1) { FactoryGirl.create(:subscription, user_id: student.id,
                          subscription_plan_id: subscription_plan_m.id,
                          stripe_token: card_token_1.id) }
  let!(:subscription_2) { FactoryGirl.create(:subscription, user_id: referred_student.id,
                                             subscription_plan_id: subscription_plan_m.id,
                                             current_status: 'active',
                                             active: 'true',
                                             stripe_token: card_token_2.id) }
  let!(:subscription_3) { FactoryGirl.create(:subscription, user_id: student.id,
                                             subscription_plan_id: subscription_plan_m.id) }
  let!(:subscription_5) { FactoryGirl.create(:subscription, user_id: referred_student.id,
                                             subscription_plan_id: subscription_plan_m.id,
                                             current_status: 'active') }

  let!(:referred_signup) { FactoryGirl.create(:referred_signup,
                                              referral_code_id: referral_code.id
                                              ) }

  let!(:invoice_created_event) {
    StripeMock.mock_webhook_event('invoice.created',
                                  subscription: subscription_3.stripe_guid,
                                  customer: student.reload.stripe_customer_id) }
  let!(:invoice_payment_failed_event_1) {
    StripeMock.mock_webhook_event('invoice.payment_failed',
                                  subscription: subscription_1.stripe_guid,
                                  next_payment_attempt: (Time.new + 24.hours),
                                  customer: student.reload.stripe_customer_id) }
  let!(:invoice_payment_failed_event_2) {
    StripeMock.mock_webhook_event('invoice.payment_failed',
                                  subscription: subscription_1.stripe_guid,
                                  customer: student.reload.stripe_customer_id) }
  let!(:customer_subscription_updated_event) { StripeMock.mock_webhook_event("customer.subscription.updated") }
  let!(:customer_subscription_created_event) { StripeMock.mock_webhook_event("customer.subscription.created", status: 'active') }

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
      describe 'invoice with valid data' do
        before(:each) do
          SubscriptionPlan.skip_callback(:update, :before, :update_on_stripe_platform)
          subscription_plan_m.stripe_guid = invoice_created_event.data.object.lines.data[0].plan.id
          subscription_plan_m.save
          subscription_3.update_attribute(:stripe_guid, invoice_created_event.data.object.subscription)
        end

        it 'created' do
          post :create, invoice_created_event.to_json

          expect(StripeApiEvent.count).to eq(1)
          sae = StripeApiEvent.last
          expect(sae.processed).to eq(true)
          expect(sae.error).to eq(false)
          expect(sae.error_message).to eq(nil)

          expect(Invoice.count).to eq(1)
          expect(InvoiceLineItem.count).to eq(invoice_created_event.data.object.lines.data.length)
        end

        it 'payment_failed first attempt' do
          mc = double
          #expect(mc).to receive(:send_card_payment_failed_email).with(account_url)
          #expect(MandrillClient).to receive(:new).and_return(mc)
          expect(subscription_1.current_status).to eq('active')

          post :create, invoice_payment_failed_event_1.to_json

          expect(StripeApiEvent.count).to eq(1)
          sae = StripeApiEvent.last
          expect(sae.processed).to eq(true)
          expect(sae.error).to eq(false)
          expect(sae.error_message).to eq(nil)
          subscription_1.reload
          expect(subscription_1.current_status).to eq('past_due')

        end

        it 'payment_failed last attempt' do
          mc = double
          #expect(mc).to receive(:send_card_payment_failed_email).with(account_url)
          #expect(MandrillClient).to receive(:new).and_return(mc)

          post :create, invoice_payment_failed_event_2.to_json

          expect(StripeApiEvent.count).to eq(1)
          sae = StripeApiEvent.last
          expect(sae.processed).to eq(true)
          expect(sae.error).to eq(false)
          expect(sae.error_message).to eq(nil)
          subscription_1.reload
          expect(subscription_1.current_status).to eq('canceled')
          expect(subscription_1.user.student_user_type_id).to eq(no_access_user_type.id)
        end

        xit 'sends data to CrushOffers on payment_succeeded' do
          student.update_attribute(:crush_offers_session_id, "1234")
          post :create, invoice_created_event.to_json
          evt = StripeMock.mock_webhook_event('invoice.payment_succeeded',
                                              customer: student.stripe_customer_id)
          uri = URI("https://crushpay.com/p.ashx?o=29&e=22&p=#{evt.data.object.total.to_f / 100.0}&c=#{evt.data.object.currency.upcase}&f=pb&r=#{student.crush_offers_session_id}&t=#{evt.data.object.id}")
          expect(Net::HTTP).to receive(:get)
                                .with(uri)
                                .and_return("<?xml version=\"1.0\" encoding=\"utf-8\"?>\r\n<result>\r\n\t<code>0</code>\r\n\t<msg>SUCCESS</msg>\r\n</result>")

          post :create, evt.to_json

          expect(StripeApiEvent.count).to eq(2)
          sae = StripeApiEvent.last
          expect(sae.processed).to eq(true)
          expect(sae.error).to eq(false)
          expect(sae.error_message).to eq(nil)
        end
      end

      describe 'invoice with invalid data' do
        before(:each) do
          SubscriptionPlan.skip_callback(:update, :before, :update_on_stripe_platform)
        end

        it 'does not send data to CrushOffers if their session ID is not set but does mark event as processed' do
          post :create, invoice_created_event.to_json
          evt = StripeMock.mock_webhook_event('invoice.payment_succeeded',
                                              customer: student.stripe_customer_id)
          uri = URI("https://crushpay.com/p.ashx?o=29&e=22&p=#{evt.data.object.total}&f=pb&r=#{student.crush_offers_session_id}&t=#{evt.data.object.id}")
          expect(Net::HTTP).not_to receive(:get)

          post :create, evt.to_json

          expect(StripeApiEvent.count).to eq(2)
          sae = StripeApiEvent.last
          expect(sae.processed).to eq(true)
          expect(sae.error).to eq(false)
        end

        it 'does not send data to CrushOffers if their session ID is not set and does not mark as processed because user is not found'  do
          post :create, invoice_created_event.to_json
          evt = StripeMock.mock_webhook_event('invoice.payment_succeeded',
                                              customer: 'fake_user_123')
          uri = URI("https://crushpay.com/p.ashx?o=29&e=22&p=#{evt.data.object.total}&f=pb&r=#{student.crush_offers_session_id}&t=#{evt.data.object.id}")
          expect(Net::HTTP).not_to receive(:get)

          post :create, evt.to_json

          expect(StripeApiEvent.count).to eq(2)
          sae = StripeApiEvent.last
          expect(sae.processed).to eq(false)
          expect(sae.error).to eq(true)
          expect(sae.error_message).to eq("Unknown user, CrushOffers session id or the user could not be found")
        end

        it 'does not send data to CrushOffers if price is not greater than 0' do
          student.update_attribute(:crush_offers_session_id, "1234")
          post :create, invoice_created_event.to_json
          evt = StripeMock.mock_webhook_event('invoice.payment_succeeded',
                                              customer: student.stripe_customer_id,
                                              total: 0.0)
          uri = URI("https://crushpay.com/p.ashx?o=29&e=22&p=#{evt.data.object.total}&f=pb&r=#{student.crush_offers_session_id}&t=#{evt.data.object.id}")
          expect(Net::HTTP).not_to receive(:get)

          post :create, evt.to_json

          expect(StripeApiEvent.count).to eq(2)
          sae = StripeApiEvent.last
          expect(sae.processed).to eq(false)
          expect(sae.error).to eq(true)
          expect(sae.error_message).to eq("Unknown user, CrushOffers session id or the user could not be found")
        end

        it 'should not process invoice.created event if user with given GUID does not exist' do
          evt = StripeMock.mock_webhook_event('invoice.created',
                                        subscription: subscription_1.stripe_guid)
          expect {
            post :create, evt.to_json
          }.not_to change { Invoice.count }

          expect(StripeApiEvent.count).to eq(1)
          sae = StripeApiEvent.last
          expect(sae.processed).to eq(false)
          expect(sae.error).to eq(true)
          expect(sae.error_message).to eq("Error creating invoice")
        end

        it 'should not process invoice.created event if subscription with given GUID does not exist' do
          evt = StripeMock.mock_webhook_event('invoice.created',
                                        customer: student.stripe_customer_id)
          expect {
            post :create, evt.to_json
          }.not_to change { Invoice.count }

          expect(StripeApiEvent.count).to eq(1)
          sae = StripeApiEvent.last
          expect(sae.processed).to eq(false)
          expect(sae.error).to eq(true)
          expect(sae.error_message).to eq("Error creating invoice")
        end

        it 'should not process invoice.created event if subscription plan from invoice line item with given GUID does not exist' do
          post :create, invoice_created_event.to_json

          # Following test should pass because transaction is rolled back. However,
          # it seems that database_cleaner messes up transactions and our transaction
          # in Invoice.build_from_stripe_data is not rolled back. That's why we skip
          # this test here (in normal mode it should work).
          # expect(Invoice.count).to eq(0)
          expect(StripeApiEvent.count).to eq(1)
          sae = StripeApiEvent.last
          expect(sae.processed).to eq(false)
          expect(sae.error).to eq(true)
          expect(sae.error_message).to eq("Error creating invoice")
        end

        it 'payment_failed' do
          evt = StripeMock.mock_webhook_event('invoice.payment_failed',
                                          subscription: subscription_1.stripe_guid)

          expect(MandrillClient).not_to receive(:new)

          post :create, evt.to_json

          expect(StripeApiEvent.count).to eq(1)
          sae = StripeApiEvent.last
          expect(sae.processed).to eq(false)
          expect(sae.error).to eq(true)
          expect(sae.error_message).to eq("User with given Stripe ID does not exist")
        end
      end

      describe 'customer.subscription.updated' do

        it 'with unknown subscription GUID' do
          post :create, customer_subscription_updated_event.to_json

          expect(StripeApiEvent.count).to eq(1)
          sae = StripeApiEvent.last
          expect(sae.processed).to eq(false)
          expect(sae.error).to eq(true)
          expect(sae.error_message).to start_with("Error updating subscription")

          expect(subscription_4.reload.current_status).to eq('trialing')
        end

        it 'with valid data' do
          evt = StripeMock.mock_webhook_event("customer.subscription.updated", status: 'trialing')
          subscription_3.update_attribute(:stripe_guid, evt.data.object.id)

          expect(MandrillClient).not_to receive(:new)
          post :create, evt.to_json

          expect(StripeApiEvent.count).to eq(1)
          sae = StripeApiEvent.last
          expect(sae.processed).to eq(true)
          expect(sae.error).to eq(false)
          expect(sae.error_message).to eq(nil)

          expect(subscription_3.reload.next_renewal_date).to eq(Time.at(evt.data.object.current_period_end.to_i).to_date)
          expect(subscription_3.current_status).to eq(evt.data.object.status)
        end
      end

      describe 'customer.subscription.created' do
        it 'marks api event as processed since users has reactivated account by subscribing to a new subscription plan' do
          subscription_5.update_attribute(:stripe_guid, customer_subscription_created_event.data.object.id)
          subscription_2.update_attribute(:current_status, 'canceled')

          post :create, customer_subscription_created_event.to_json

          expect(StripeApiEvent.count).to eq(1)
          sae = StripeApiEvent.last
          expect(sae.processed).to eq(true)
          expect(sae.error).to eq(false)
          expect(sae.error_message).to eq(nil)
        end


        it 'does not marks api event as processed because users old plan is still valid' do
          subscription_5.update_attribute(:stripe_guid, customer_subscription_created_event.data.object.id)

          post :create, customer_subscription_created_event.to_json

          expect(StripeApiEvent.count).to eq(1)
          sae = StripeApiEvent.last
          expect(sae.processed).to eq(false)
          expect(sae.error).to eq(true)
          expect(sae.error_message).to eq("API Event with Stripe ID #{customer_subscription_created_event.data.object.id} was created but the necessary conditions for the user were not met.")
        end

      end
    end

  end

end
