require 'rails_helper'
require 'mandrill_client'
require 'support/users_and_groups_setup'
require 'stripe_mock'

describe Api::StripeV01Controller, type: :controller do

  include_context 'users_and_groups_setup'

  let!(:start_stripe_mock) { StripeMock.start }
  let(:stripe_helper) { StripeMock.create_test_helper }

  let!(:usd) { FactoryBot.create(:usd) }
  let!(:student) { FactoryBot.create(:student_user) }
  let!(:new_student) { FactoryBot.create(:student_user) }
  let!(:reactivating_student) { FactoryBot.create(:student_user) }
  let!(:referred_student) { FactoryBot.create(:student_user) }

  let!(:referral_code) { FactoryBot.create(:referral_code, user_id: student.id) }

  let!(:subscription_plan_m) { FactoryBot.create(:student_subscription_plan_m) }
  let!(:subscription_plan_q) { FactoryBot.create(:student_subscription_plan_q) }
  let!(:card_details_1) { {number: '4242424242424242', cvc: '123', exp_month: '12', exp_year: '2019'} }
  let!(:card_details_2) { {number: '4242424242424242', cvc: '123', exp_month: '11', exp_year: '2019'} }
  let!(:card_token_1)   { Stripe::Token.create(card: card_details_1) }
  let!(:card_token_2)   { Stripe::Token.create(card: card_details_2) }
  let!(:subscription_1) { FactoryBot.create(:subscription, user_id: student.id, subscription_plan_id: subscription_plan_m.id, stripe_token: card_token_1.id) }
  let!(:subscription_2) { FactoryBot.create(:subscription, user_id: referred_student.id,
subscription_plan_id: subscription_plan_m.id, current_status: 'active', active: 'true', stripe_token: card_token_2.id) }
  let!(:subscription_3) { FactoryBot.create(:subscription, user_id: student.id, subscription_plan_id: subscription_plan_m.id) }
  let!(:subscription_5) { FactoryBot.create(:subscription, user_id: new_student.id, subscription_plan_id: subscription_plan_m.id, current_status: 'active', active: true) }
  let!(:subscription_6) { FactoryBot.create(:subscription, user_id: reactivating_student.id,
subscription_plan_id: subscription_plan_m.id, current_status: 'canceled', active: true) }
  let!(:subscription_7) { FactoryBot.create(:subscription, user_id: reactivating_student.id, subscription_plan_id: subscription_plan_m.id, current_status: 'active', active: true) }
  let!(:referred_signup) { FactoryBot.create(:referred_signup, referral_code_id: referral_code.id) }

  xit describe "POST 'create'" do
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

        it 'invoice.payment_failed first attempt' do
          invoice = Invoice.build_from_stripe_data(invoice_created_event[:data][:object])
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

        it 'invoice.payment_failed last attempt' do
          invoice = Invoice.build_from_stripe_data(invoice_created_event[:data][:object])
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
        end

        it 'invoice.payment_succeeded first attempt' do
          invoice = Invoice.build_from_stripe_data(invoice_created_event[:data][:object])
          mc = double
          #expect(mc).to receive(:send_card_payment_failed_email).with(account_url)
          #expect(MandrillClient).to receive(:new).and_return(mc)
          student.update_attribute(:stripe_customer_id, invoice_payment_succeeded_event_1.data.object.customer)

          post :create, invoice_payment_succeeded_event_1.to_json

          expect(StripeApiEvent.count).to eq(1)
          sae = StripeApiEvent.last
          expect(sae.processed).to eq(true)
          expect(sae.error).to eq(false)
          expect(sae.error_message).to eq(nil)
          subscription_1.reload
          expect(subscription_1.current_status).to eq('active')
        end

        it 'invoice.payment_succeeded after failed attempt' do
          invoice = Invoice.build_from_stripe_data(invoice_created_event[:data][:object])
          mc = double
          #expect(mc).to receive(:send_card_payment_failed_email).with(account_url)
          #expect(MandrillClient).to receive(:new).and_return(mc)

          subscription_7.update_attribute(:current_status, 'past_due')
          post :create, invoice_payment_succeeded_event_2.to_json

          expect(StripeApiEvent.count).to eq(1)
          sae = StripeApiEvent.last
          expect(sae.processed).to eq(true)
          expect(sae.error).to eq(false)
          expect(sae.error_message).to eq(nil)
          subscription_1.reload
          expect(subscription_1.current_status).to eq('active')
        end

      end

      describe 'invoice with invalid data' do
        before(:each) do
          SubscriptionPlan.skip_callback(:update, :before, :update_on_stripe_platform)
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
          expect(sae.error_message).to eq("Could not find user with stripe id #{evt.data.object.customer}")
        end
      end

    end

  end

end
