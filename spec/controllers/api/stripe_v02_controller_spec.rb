require 'rails_helper'
require 'support/stripe_web_mock_helpers'


describe Api::StripeV02Controller, type: :controller do

  let!(:gbp) { FactoryBot.create(:gbp) }
  let!(:uk) { FactoryBot.create(:uk, currency_id: gbp.id) }
  let!(:uk_vat_code) { FactoryBot.create(:vat_code, country_id: uk.id) }
  let!(:subscription_plan_gbp_m) { FactoryBot.create(:student_subscription_plan_m,
                                                     currency_id: gbp.id, price: 7.50, stripe_guid: 'stripe_plan_guid_m') }
  let!(:subscription_plan_gbp_q) { FactoryBot.create(:student_subscription_plan_q,
                                                     currency_id: gbp.id, price: 22.50, stripe_guid: 'stripe_plan_guid_q') }
  let!(:subscription_plan_gbp_y) { FactoryBot.create(:student_subscription_plan_y,
                                                     currency_id: gbp.id, price: 87.99, stripe_guid: 'stripe_plan_guid_y') }
  let!(:student_user_group ) { FactoryBot.create(:student_user_group ) }
  let!(:valid_trial_student) { FactoryBot.create(:valid_free_trial_student,
                                                 user_group_id: student_user_group.id) }
  let!(:valid_trial_student_access) { FactoryBot.create(:valid_free_trial_student_access,
                                                        user_id: valid_trial_student.id) }
  let!(:valid_subscription_student) { FactoryBot.create(:valid_subscription_student,
                                                        user_group_id: student_user_group.id) }
  let!(:valid_subscription_student_access) { FactoryBot.create(:trial_student_access,
                                                               user_id: valid_subscription_student.id) }

  let!(:valid_subscription) { FactoryBot.create(:valid_subscription, user_id: valid_subscription_student.id,
                                                subscription_plan_id: subscription_plan_gbp_m.id,
                                                stripe_customer_id: valid_subscription_student.stripe_customer_id ) }
  let!(:default_card) { FactoryBot.create(:subscription_payment_card, user_id: valid_subscription_student.id,
                                          is_default_card: true, stripe_card_guid: 'guid_222',
                                          status: 'card-live' ) }



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
      describe 'with valid data' do

        it 'invoice.created event' do

          post_request_body = {"id": "evt_00000000000001", "object": "event", "api_version": "2017-05-25", "created": 1326853478, "data": {"object": {"id": "in_1APVed2eZvKYlo2CP6dsoJTo", "object": "invoice", "amount_due": 599, "application_fee": nil, "attempt_count": 1, "attempted": true, "charge": "ch_1APVed2eZvKYlo2C1QNH6jru", "closed": true, "currency": "gbp", "customer": valid_trial_student.stripe_customer_id, "date": 1496232623, "description": nil, "discount": nil, "ending_balance": 0, "forgiven": false, "lines": {"data": [{"id": valid_subscription.stripe_guid, "object": "line_item", "amount": 599, "currency": "gbp", "description": nil, "discountable": true, "livemode": true, "metadata": {}, "period": {"start": 1498824623, "end": 1501503023}, "plan": {"id": subscription_plan_gbp_m.stripe_guid, "object": "plan", "amount": 999, "created": 1496222010, "currency": "gbp", "interval": "month", "interval_count": 1, "livemode": false, "metadata": {}, "name": subscription_plan_gbp_m.name, "statement_descriptor": nil, "trial_period_days": nil}, "proration": false, "quantity": 1, "subscription": nil, "subscription_item": "si_1APVed2eZvKYlo2C387JnMRE", "type": "subscription"}], "total_count": 1, "object": "list", "url": "/v1/invoices/in_1APVed2eZvKYlo2CP6dsoJTo/lines"}, "livemode": false, "metadata": {}, "next_payment_attempt": nil, "paid": true, "period_end": 1496232623, "period_start": 1496232623, "receipt_number": nil, "starting_balance": 0, "statement_descriptor": nil, "subscription": valid_subscription.stripe_guid, "subtotal": 599, "tax": nil, "tax_percent": nil, "total": 599, "webhooks_delivered_at": 1496232630}}, "livemode": false, "pending_webhooks": 1, "request": "req_Al1inviVvNH7df", "type": "invoice.created"}


          url = 'https://api.stripe.com/v1/events/evt_00000000000001'
          stub_event_get_request(url, post_request_body)

          post :create, post_request_body.to_json

          expect(StripeApiEvent.count).to eq(1)
          sae = StripeApiEvent.last
          expect(sae.processed).to eq(true)
          expect(sae.error).to eq(false)
          expect(sae.error_message).to eq(nil)
          expect(Invoice.count).to eq(1)
          invoice = Invoice.last
          expect(invoice.user_id).to eq(valid_trial_student.id)
          expect(invoice.subscription_id).to eq(valid_subscription.id)
          expect(invoice.stripe_guid).to eq('in_1APVed2eZvKYlo2CP6dsoJTo')
          expect(InvoiceLineItem.count).to eq(1)
        end

        xit 'invoice.payment_failed first attempt' do

          invoice = Invoice.build_from_stripe_data(invoice_created_event_2[:data][:object])
          #TODO - Fix this Mandrill Test
          #mc = double
          #expect(mc).to receive(:send_card_payment_failed_email).with(account_url)
          #expect(MandrillClient).to receive(:new).and_return(mc)
          expect(subscription_2.current_status).to eq('active')

          post :create, invoice_payment_failed_event_1.to_json

          expect(StripeApiEvent.count).to eq(1)
          sae = StripeApiEvent.last
          expect(sae.processed).to eq(true)
          expect(sae.error).to eq(false)
          expect(sae.error_message).to eq(nil)
          subscription_2.reload
          expect(subscription_2.current_status).to eq('past_due')

        end

        xit 'invoice.payment_failed last attempt' do
          invoice = Invoice.build_from_stripe_data(invoice_created_event_2[:data][:object])
          #TODO - Fix this Mandrill Test
          #mc = double
          #expect(mc).to receive(:send_card_payment_failed_email).with(account_url)
          #expect(MandrillClient).to receive(:new).and_return(mc)

          post :create, invoice_payment_failed_event_2.to_json

          expect(StripeApiEvent.count).to eq(1)
          sae = StripeApiEvent.last
          expect(sae.processed).to eq(true)
          expect(sae.error).to eq(false)
          expect(sae.error_message).to eq(nil)
          subscription_2.reload
          expect(subscription_2.current_status).to eq('canceled')
        end

        xit 'invoice.payment_succeeded first attempt' do
          invoice = Invoice.build_from_stripe_data(invoice_created_event_1[:data][:object])
          #TODO - Fix this Mandrill Test
          #mc = double
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

        xit 'invoice.payment_succeeded after failed attempt' do
          invoice = Invoice.build_from_stripe_data(invoice_created_event_2[:data][:object])
          #TODO - Fix this Mandrill Test
          #mc = double
          #expect(mc).to receive(:send_card_payment_failed_email).with(account_url)
          #expect(MandrillClient).to receive(:new).and_return(mc)

          subscription_3.update_attribute(:current_status, 'past_due')
          post :create, invoice_payment_succeeded_event_2.to_json

          expect(StripeApiEvent.count).to eq(1)
          sae = StripeApiEvent.last
          expect(sae.processed).to eq(true)
          expect(sae.error).to eq(false)
          expect(sae.error_message).to eq(nil)
          subscription_3.reload
          expect(subscription_3.current_status).to eq('active')
        end

        xit 'customer.subscription.deleted event' do
          subscription_4.update_attribute(:stripe_guid, customer_subscription_deleted_event.data.object.id)

          #TODO - Fix this Mandrill Test
          #mc = double
          #expect(mc).to receive(:send_card_payment_failed_email).with(account_url)
          #expect(MandrillClient).to receive(:new).and_return(mc)

          post :create, customer_subscription_deleted_event.to_json

          expect(StripeApiEvent.count).to eq(1)
          sae = StripeApiEvent.last
          expect(sae.processed).to eq(true)
          expect(sae.error).to eq(false)
          expect(sae.error_message).to eq(nil)
          subscription_4.reload
          expect(subscription_4.current_status).to eq('canceled')
        end

      end

      describe 'invoice with invalid data' do
        #TODO should add more tests for bad data, payment_failed and subscription_deleted are not tested
        before(:each) do
          SubscriptionPlan.skip_callback(:update, :before, :update_on_stripe_platform)
        end

        xit 'should not process invoice.created event if user with given GUID does not exist' do
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

        xit 'should not process invoice.created event if subscription with given GUID does not exist' do
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

        xit 'should not process invoice.created event if subscription plan from invoice line item with given GUID does not exist' do
          post :create, invoice_created_event_1.to_json

          # Following test should pass because transaction is rolled back. However,
          # xit seems that database_cleaner messes up transactions and our transaction
          # in Invoice.build_from_stripe_data is not rolled back. That's why we skip
          # this test here (in normal mode xit should work).
          # expect(Invoice.count).to eq(0)
          expect(StripeApiEvent.count).to eq(1)
          sae = StripeApiEvent.last
          expect(sae.processed).to eq(false)
          expect(sae.error).to eq(true)
          expect(sae.error_message).to eq("Error creating invoice")
        end

        xit 'payment_failed' do
          evt = StripeMock.mock_webhook_event('invoice.payment_failed',
                                              subscription: subscription_1.stripe_guid)

          expect(MandrillClient).not_to receive(:new)

          post :create, evt.to_json

          expect(StripeApiEvent.count).to eq(1)
          sae = StripeApiEvent.last
          expect(sae.processed).to eq(false)
          expect(sae.error).to eq(true)
        end
      end

    end

  end

end
