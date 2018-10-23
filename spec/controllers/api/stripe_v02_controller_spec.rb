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
  let!(:invoice) { FactoryBot.create(:invoice, user_id: valid_subscription_student.id,
                                     subscription_id: valid_subscription.id, total: 99 ,
                                     currency_id: gbp.id, stripe_guid: 'in_1APVed2eZvKYlo2CP6dsoJTo') }
  let!(:charge) { FactoryBot.create(:charge, user_id: valid_subscription_student.id,
                                     subscription_id: valid_subscription.id, invoice_id: invoice.id,
                                    subscription_payment_card_id: default_card.id, currency_id: gbp.id,
                                    stripe_guid: 'ch_21334nj453h', amount: 100, status: 'succeeded') }

  let!(:coupon) { FactoryBot.create(:coupon, name: '25.5% off', code: '25_5OFF', duration: 'repeating') }



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
          expect(Invoice.count).to eq(2)
          invoice = Invoice.last
          expect(invoice.subscription_id).to eq(valid_subscription.id)
          expect(invoice.stripe_guid).to eq('in_1APVed2eZvKYlo2CP6dsoJTo')
          expect(InvoiceLineItem.count).to eq(1)
        end

        it 'invoice.payment_failed first attempt' do

          post_request_body = {"id": "evt_00000000000002", "object": "event", "api_version": "2017-05-25", "created": 1326853478, "data": {"object": {"id": "in_1APVed2eZvKYlo2CP6dsoJTo", "object": "invoice", "amount_due": 599, "application_fee": nil, "attempt_count": 1, "attempted": true, "charge": "ch_1APVed2eZvKYlo2C1QNH6jru", "closed": true, "currency": "gbp", "customer": valid_subscription_student.stripe_customer_id, "date": 1496232623, "description": nil, "discount": nil, "ending_balance": 0, "forgiven": false, "lines": {"data": [{"id": valid_subscription.stripe_guid, "object": "line_item", "amount": 599, "currency": "gbp", "description": nil, "discountable": true, "livemode": true, "metadata": {}, "period": {"start": 1498824623, "end": 1501503023}, "plan": {"id": subscription_plan_gbp_m.stripe_guid, "object": "plan", "amount": 999, "created": 1496222010, "currency": "gbp", "interval": "month", "interval_count": 1, "livemode": false, "metadata": {}, "name": subscription_plan_gbp_m.name, "statement_descriptor": nil, "trial_period_days": nil}, "proration": false, "quantity": 1, "subscription": nil, "subscription_item": "si_1APVed2eZvKYlo2C387JnMRE", "type": "subscription"}], "total_count": 1, "object": "list", "url": "/v1/invoices/in_1APVed2eZvKYlo2CP6dsoJTo/lines"}, "livemode": false, "metadata": {}, "next_payment_attempt": nil, "paid": true, "period_end": 1496232623, "period_start": 1496232623, "receipt_number": nil, "starting_balance": 0, "statement_descriptor": nil, "subscription": valid_subscription.stripe_guid, "subtotal": 599, "tax": nil, "tax_percent": nil, "total": 599, "webhooks_delivered_at": 1496232630}}, "livemode": false, "pending_webhooks": 1, "request": "req_Al1inviVfg7df", "type": "invoice.payment_failed"}

          event_url = 'https://api.stripe.com/v1/events/evt_00000000000002'
          stub_event_get_request(event_url, post_request_body)

          invoice_response_body = {"id": invoice.stripe_guid, "object": "invoice", "amount_due": 500, "amount_paid": 0, "amount_remaining": 500, "application_fee": nil, "attempt_count": 4, "attempted": true, "auto_advance": true, "billing": "charge_automatically", "billing_reason": "subscription", "charge": "ch_5WybupUzcscclq", "closed": false, "currency": "gbp", "customer": valid_subscription_student.stripe_customer_id, "date": 1420193829, "description": nil, "discount": nil, "due_date": nil, "ending_balance": 0, "forgiven": false, "hosted_invoice_url": "https://pay.stripe.com/invoice/invst_0kScQzgfwvufrbPULAPttcBSCi", "invoice_pdf": "https://pay.stripe.com/invoice/invst_0kScQzgfwvufrbPULAPttcBSCi/pdf", "lines": {"data": [{"id": "sli_859339fd5ed203", "object": "line_item", "amount": 0, "currency": "gbp", "description": "Trial period for LearnSignal Test 267", "discountable": true, "livemode": false, "metadata": {}, "period": {"end": 1540807556, "start": 1540202756}, "plan": {"id": subscription_plan_gbp_m.stripe_guid, "object": "plan", "active": true, "aggregate_usage": nil, "amount": 999, "billing_scheme": "per_unit", "created": 1462284968, "currency": "gbp", "interval": "month", "interval_count": 1, "livemode": false, "metadata": {}, "nickname": nil, "product": "prod_BTuUwcCciIESD8", "tiers": nil, "tiers_mode": nil, "transform_usage": nil, "trial_period_days": 7, "usage_type": "licensed"}, "proration": false, "quantity": 1, "subscription": valid_subscription.stripe_guid, "subscription_item": "si_DpfdybeQdJlQfY", "type": "subscription"}], "has_more": false, "object": "list", "url": "/v1/invoices/in_5RLAdp7JkW1w6I/lines"}, "livemode": false, "metadata": {}, "next_payment_attempt": nil, "number": nil, "paid": false, "period_end": 1420193754, "period_start": 1417515354, "receipt_number": nil, "starting_balance": 0, "statement_descriptor": nil, "subscription": valid_subscription.stripe_guid, "subtotal": 500, "tax": nil, "tax_percent": nil, "total": 500, "webhooks_delivered_at": 1420193835}
          invoice_url = "https://api.stripe.com/v1/invoices/#{invoice.stripe_guid}"
          stub_invoice_get_request(invoice_url, invoice_response_body)

          sources = {"id": "src_Do8swBcNDszFmc", "object": "source", "client_secret": "src_client_secret_Do8sRLByihYpru4LuNCGYP8L",
                     "created": 1539850277, "currency": "eur", "flow": "receiver", "livemode": false, "status": "pending"
          }
          subscriptions = {"id": valid_subscription.stripe_guid, "object": "subscription", "livemode": false,
                           "current_period_end": 1540455078, "plan": {"id": subscription_plan_gbp_m.stripe_guid,
                                                                      "object": "plan", "active": true,
                                                                      "amount": 999, "livemode": false }, "status": "past_due"}

          get_response_body = {"id": valid_subscription_student.stripe_customer_id, "object": "customer", "account_balance": 0,
                               "invoice_prefix": "1C44D6D", "livemode": false,"default_source": "src_Do8swBcNDszFmc",
                               "sources": {"object": "list", "data": [sources], "has_more": false, "total_count": 0,
                                           "url": "/v1/customers/cus_Do8skFvJFlWtvy/sources"},
                               "subscriptions": {"object": "list","data": [subscriptions],"has_more": false,"total_count": 0,
                                                 "url": "/v1/customers/#{valid_subscription_student.stripe_customer_id}/subscriptions"}}

          customer_url = "https://api.stripe.com/v1/customers/#{valid_subscription_student.stripe_customer_id}"
          stub_customer_get_request(customer_url, get_response_body)

          subscription_url = "https://api.stripe.com/v1/customers/#{valid_subscription_student.stripe_customer_id}/subscriptions/#{valid_subscription.stripe_guid}"
          subscription = {      "id": valid_subscription.stripe_guid, "object": "subscription",
                                "billing": "charge_automatically", "status": "past_due",
                                "billing_cycle_anchor": 1540455078, "cancel_at_period_end": false,
                                "created": 1539850278, "current_period_end": 1540455078, "current_period_start": 1539850278,
                                "customer": valid_subscription_student.stripe_customer_id, "plan": {"livemode": false}}

          stub_subscription_get_request(subscription_url, subscription)

          # Add Mandrill Post Stub
          expect(valid_subscription.current_status).to eq('active')
          post :create, post_request_body.to_json

          expect(StripeApiEvent.count).to eq(1)
          sae = StripeApiEvent.last
          expect(sae.processed).to eq(true)
          expect(sae.error).to eq(false)
          expect(sae.error_message).to eq(nil)
          valid_subscription.reload
          expect(valid_subscription.current_status).to eq('past_due')

        end

        it 'invoice.payment_failed last attempt' do

          post_request_body = {"id": "evt_00000000000002", "object": "event", "api_version": "2017-05-25", "created": 1326853478, "data": {"object": {"id": "in_1APVed2eZvKYlo2CP6dsoJTo", "object": "invoice", "amount_due": 599, "application_fee": nil, "attempt_count": 1, "attempted": true, "charge": "ch_1APVed2eZvKYlo2C1QNH6jru", "closed": true, "currency": "gbp", "customer": valid_subscription_student.stripe_customer_id, "date": 1496232623, "description": nil, "discount": nil, "ending_balance": 0, "forgiven": false, "lines": {"data": [{"id": valid_subscription.stripe_guid, "object": "line_item", "amount": 599, "currency": "gbp", "description": nil, "discountable": true, "livemode": true, "metadata": {}, "period": {"start": 1498824623, "end": 1501503023}, "plan": {"id": subscription_plan_gbp_m.stripe_guid, "object": "plan", "amount": 999, "created": 1496222010, "currency": "gbp", "interval": "month", "interval_count": 1, "livemode": false, "metadata": {}, "name": subscription_plan_gbp_m.name, "statement_descriptor": nil, "trial_period_days": nil}, "proration": false, "quantity": 1, "subscription": nil, "subscription_item": "si_1APVed2eZvKYlo2C387JnMRE", "type": "subscription"}], "total_count": 1, "object": "list", "url": "/v1/invoices/in_1APVed2eZvKYlo2CP6dsoJTo/lines"}, "livemode": false, "metadata": {}, "next_payment_attempt": nil, "paid": true, "period_end": 1496232623, "period_start": 1496232623, "receipt_number": nil, "starting_balance": 0, "statement_descriptor": nil, "subscription": valid_subscription.stripe_guid, "subtotal": 599, "tax": nil, "tax_percent": nil, "total": 599, "webhooks_delivered_at": 1496232630}}, "livemode": false, "pending_webhooks": 1, "request": "req_Al1inviVfg7df", "type": "invoice.payment_failed"}

          event_url = 'https://api.stripe.com/v1/events/evt_00000000000002'
          stub_event_get_request(event_url, post_request_body)

          invoice_response_body = {"id": invoice.stripe_guid, "object": "invoice", "amount_due": 500, "amount_paid": 0, "amount_remaining": 500, "application_fee": nil, "attempt_count": 4, "attempted": true, "auto_advance": true, "billing": "charge_automatically", "billing_reason": "subscription", "charge": "ch_5WybupUzcscclq", "closed": false, "currency": "gbp", "customer": valid_subscription_student.stripe_customer_id, "date": 1420193829, "description": nil, "discount": nil, "due_date": nil, "ending_balance": 0, "forgiven": false, "hosted_invoice_url": "https://pay.stripe.com/invoice/invst_0kScQzgfwvufrbPULAPttcBSCi", "invoice_pdf": "https://pay.stripe.com/invoice/invst_0kScQzgfwvufrbPULAPttcBSCi/pdf", "lines": {"data": [{"id": "sli_859339fd5ed203", "object": "line_item", "amount": 0, "currency": "gbp", "description": "Trial period for LearnSignal Test 267", "discountable": true, "livemode": false, "metadata": {}, "period": {"end": 1540807556, "start": 1540202756}, "plan": {"id": subscription_plan_gbp_m.stripe_guid, "object": "plan", "active": true, "aggregate_usage": nil, "amount": 999, "billing_scheme": "per_unit", "created": 1462284968, "currency": "gbp", "interval": "month", "interval_count": 1, "livemode": false, "metadata": {}, "nickname": nil, "product": "prod_BTuUwcCciIESD8", "tiers": nil, "tiers_mode": nil, "transform_usage": nil, "trial_period_days": 7, "usage_type": "licensed"}, "proration": false, "quantity": 1, "subscription": valid_subscription.stripe_guid, "subscription_item": "si_DpfdybeQdJlQfY", "type": "subscription"}], "has_more": false, "object": "list", "url": "/v1/invoices/in_5RLAdp7JkW1w6I/lines"}, "livemode": false, "metadata": {}, "next_payment_attempt": nil, "number": nil, "paid": false, "period_end": 1420193754, "period_start": 1417515354, "receipt_number": nil, "starting_balance": 0, "statement_descriptor": nil, "subscription": valid_subscription.stripe_guid, "subtotal": 500, "tax": nil, "tax_percent": nil, "total": 500, "webhooks_delivered_at": 1420193835}
          invoice_url = "https://api.stripe.com/v1/invoices/#{invoice.stripe_guid}"
          stub_invoice_get_request(invoice_url, invoice_response_body)

          sources = {"id": "src_Do8swBcNDszFmc", "object": "source", "client_secret": "src_client_secret_Do8sRLByihYpru4LuNCGYP8L",
                     "created": 1539850277, "currency": "eur", "flow": "receiver", "livemode": false, "status": "pending"
          }
          subscriptions = {"id": valid_subscription.stripe_guid, "object": "subscription", "livemode": false,
                           "current_period_end": 1540455078, "plan": {"id": subscription_plan_gbp_m.stripe_guid,
                                                                      "object": "plan", "active": true,
                                                                      "amount": 999, "livemode": false }, "status": "canceled"}

          get_response_body = {"id": valid_subscription_student.stripe_customer_id, "object": "customer", "account_balance": 0,
                               "invoice_prefix": "1C44D6D", "livemode": false,"default_source": "src_Do8swBcNDszFmc",
                               "sources": {"object": "list", "data": [sources], "has_more": false, "total_count": 0,
                                           "url": "/v1/customers/cus_Do8skFvJFlWtvy/sources"},
                               "subscriptions": {"object": "list","data": [subscriptions],"has_more": false,"total_count": 0,
                                                 "url": "/v1/customers/#{valid_subscription_student.stripe_customer_id}/subscriptions"}}

          customer_url = "https://api.stripe.com/v1/customers/#{valid_subscription_student.stripe_customer_id}"
          stub_customer_get_request(customer_url, get_response_body)

          subscription_url = "https://api.stripe.com/v1/customers/#{valid_subscription_student.stripe_customer_id}/subscriptions/#{valid_subscription.stripe_guid}"
          subscription = {      "id": valid_subscription.stripe_guid, "object": "subscription",
                                "billing": "charge_automatically", "status": "canceled",
                                "billing_cycle_anchor": 1540455078, "cancel_at_period_end": false,
                                "created": 1539850278, "current_period_end": 1540455078, "current_period_start": 1539850278,
                                "customer": valid_subscription_student.stripe_customer_id, "plan": {"livemode": false}}

          stub_subscription_get_request(subscription_url, subscription)

          post :create, post_request_body.to_json

          expect(StripeApiEvent.count).to eq(1)
          sae = StripeApiEvent.last
          expect(sae.processed).to eq(true)
          expect(sae.error).to eq(false)
          expect(sae.error_message).to eq(nil)
          valid_subscription.reload
          expect(valid_subscription.current_status).to eq('canceled')
        end

        it 'invoice.payment_succeeded first attempt' do

          post_request_body = {"id": "evt_00000000000002", "object": "event", "api_version": "2017-05-25", "created": 1326853478, "data": {"object": {"id": "in_1APVed2eZvKYlo2CP6dsoJTo", "object": "invoice", "amount_due": 599, "application_fee": nil, "attempt_count": 1, "attempted": true, "charge": "ch_1APVed2eZvKYlo2C1QNH6jru", "closed": true, "currency": "gbp", "customer": valid_subscription_student.stripe_customer_id, "date": 1496232623, "description": nil, "discount": nil, "ending_balance": 0, "forgiven": false, "lines": {"data": [{"id": valid_subscription.stripe_guid, "object": "line_item", "amount": 599, "currency": "gbp", "description": nil, "discountable": true, "livemode": true, "metadata": {}, "period": {"start": 1498824623, "end": 1501503023}, "plan": {"id": subscription_plan_gbp_m.stripe_guid, "object": "plan", "amount": 999, "created": 1496222010, "currency": "gbp", "interval": "month", "interval_count": 1, "livemode": false, "metadata": {}, "name": subscription_plan_gbp_m.name, "statement_descriptor": nil, "trial_period_days": nil}, "proration": false, "quantity": 1, "subscription": nil, "subscription_item": "si_1APVed2eZvKYlo2C387JnMRE", "type": "subscription"}], "total_count": 1, "object": "list", "url": "/v1/invoices/in_1APVed2eZvKYlo2CP6dsoJTo/lines"}, "livemode": false, "metadata": {}, "next_payment_attempt": nil, "paid": true, "period_end": 1496232623, "period_start": 1496232623, "receipt_number": nil, "starting_balance": 0, "statement_descriptor": nil, "subscription": valid_subscription.stripe_guid, "subtotal": 599, "tax": nil, "tax_percent": nil, "total": 599, "webhooks_delivered_at": 1496232630}}, "livemode": false, "pending_webhooks": 1, "request": "req_Al1inviVfg7df", "type": "invoice.payment_succeeded"}

          event_url = 'https://api.stripe.com/v1/events/evt_00000000000002'
          stub_event_get_request(event_url, post_request_body)

          invoice_response_body = {"id": invoice.stripe_guid, "object": "invoice", "amount_due": 500, "amount_paid": 0, "amount_remaining": 500, "application_fee": nil, "attempt_count": 4, "attempted": true, "auto_advance": true, "billing": "charge_automatically", "billing_reason": "subscription", "charge": "ch_5WybupUzcscclq", "closed": false, "currency": "gbp", "customer": valid_subscription_student.stripe_customer_id, "date": 1420193829, "description": nil, "discount": nil, "due_date": nil, "ending_balance": 0, "forgiven": false, "hosted_invoice_url": "https://pay.stripe.com/invoice/invst_0kScQzgfwvufrbPULAPttcBSCi", "invoice_pdf": "https://pay.stripe.com/invoice/invst_0kScQzgfwvufrbPULAPttcBSCi/pdf", "lines": {"data": [{"id": "sli_859339fd5ed203", "object": "line_item", "amount": 0, "currency": "gbp", "description": "Trial period for LearnSignal Test 267", "discountable": true, "livemode": false, "metadata": {}, "period": {"end": 1540807556, "start": 1540202756}, "plan": {"id": subscription_plan_gbp_m.stripe_guid, "object": "plan", "active": true, "aggregate_usage": nil, "amount": 999, "billing_scheme": "per_unit", "created": 1462284968, "currency": "gbp", "interval": "month", "interval_count": 1, "livemode": false, "metadata": {}, "nickname": nil, "product": "prod_BTuUwcCciIESD8", "tiers": nil, "tiers_mode": nil, "transform_usage": nil, "trial_period_days": 7, "usage_type": "licensed"}, "proration": false, "quantity": 1, "subscription": valid_subscription.stripe_guid, "subscription_item": "si_DpfdybeQdJlQfY", "type": "subscription"}], "has_more": false, "object": "list", "url": "/v1/invoices/in_5RLAdp7JkW1w6I/lines"}, "livemode": false, "metadata": {}, "next_payment_attempt": nil, "number": nil, "paid": false, "period_end": 1420193754, "period_start": 1417515354, "receipt_number": nil, "starting_balance": 0, "statement_descriptor": nil, "subscription": valid_subscription.stripe_guid, "subtotal": 500, "tax": nil, "tax_percent": nil, "total": 500, "webhooks_delivered_at": 1420193835}
          invoice_url = "https://api.stripe.com/v1/invoices/#{invoice.stripe_guid}"
          stub_invoice_get_request(invoice_url, invoice_response_body)

          sources = {"id": "src_Do8swBcNDszFmc", "object": "source", "client_secret": "src_client_secret_Do8sRLByihYpru4LuNCGYP8L",
                     "created": 1539850277, "currency": "eur", "flow": "receiver", "livemode": false, "status": "pending"
          }
          subscriptions = {"id": valid_subscription.stripe_guid, "object": "subscription", "livemode": false,
                           "current_period_end": 1540455078, "plan": {"id": subscription_plan_gbp_m.stripe_guid,
                                                                      "object": "plan", "active": true,
                                                                      "amount": 999, "livemode": false }, "status": "active"}


          subscription_url = "https://api.stripe.com/v1/subscriptions/#{valid_subscription.stripe_guid}"
          subscription = {      "id": valid_subscription.stripe_guid, "object": "subscription",
                                "billing": "charge_automatically", "status": "active",
                                "billing_cycle_anchor": 1540455078, "cancel_at_period_end": false,
                                "created": 1539850278, "current_period_end": 1540455078, "current_period_start": 1539850278,
                                "customer": valid_subscription_student.stripe_customer_id, "plan": {"livemode": false}}

          stub_subscription_get_request(subscription_url, subscription)

          post :create, post_request_body.to_json

          expect(StripeApiEvent.count).to eq(1)
          sae = StripeApiEvent.last
          expect(sae.processed).to eq(true)
          expect(sae.error).to eq(false)
          expect(sae.error_message).to eq(nil)
          valid_subscription.reload
          expect(valid_subscription.current_status).to eq('active')
        end

        it 'invoice.payment_succeeded after failed attempt' do
          valid_subscription.update_column(:current_status, 'past_due')

          post_request_body = {"id": "evt_00000000000002", "object": "event", "api_version": "2017-05-25", "created": 1326853478, "data": {"object": {"id": "in_1APVed2eZvKYlo2CP6dsoJTo", "object": "invoice", "amount_due": 599, "application_fee": nil, "attempt_count": 1, "attempted": true, "charge": "ch_1APVed2eZvKYlo2C1QNH6jru", "closed": true, "currency": "gbp", "customer": valid_subscription_student.stripe_customer_id, "date": 1496232623, "description": nil, "discount": nil, "ending_balance": 0, "forgiven": false, "lines": {"data": [{"id": valid_subscription.stripe_guid, "object": "line_item", "amount": 599, "currency": "gbp", "description": nil, "discountable": true, "livemode": true, "metadata": {}, "period": {"start": 1498824623, "end": 1501503023}, "plan": {"id": subscription_plan_gbp_m.stripe_guid, "object": "plan", "amount": 999, "created": 1496222010, "currency": "gbp", "interval": "month", "interval_count": 1, "livemode": false, "metadata": {}, "name": subscription_plan_gbp_m.name, "statement_descriptor": nil, "trial_period_days": nil}, "proration": false, "quantity": 1, "subscription": nil, "subscription_item": "si_1APVed2eZvKYlo2C387JnMRE", "type": "subscription"}], "total_count": 1, "object": "list", "url": "/v1/invoices/in_1APVed2eZvKYlo2CP6dsoJTo/lines"}, "livemode": false, "metadata": {}, "next_payment_attempt": nil, "paid": true, "period_end": 1496232623, "period_start": 1496232623, "receipt_number": nil, "starting_balance": 0, "statement_descriptor": nil, "subscription": valid_subscription.stripe_guid, "subtotal": 599, "tax": nil, "tax_percent": nil, "total": 599, "webhooks_delivered_at": 1496232630}}, "livemode": false, "pending_webhooks": 1, "request": "req_Al1inviVfg7df", "type": "invoice.payment_succeeded"}

          event_url = 'https://api.stripe.com/v1/events/evt_00000000000002'
          stub_event_get_request(event_url, post_request_body)

          invoice_response_body = {"id": invoice.stripe_guid, "object": "invoice", "amount_due": 500, "amount_paid": 0, "amount_remaining": 500, "application_fee": nil, "attempt_count": 4, "attempted": true, "auto_advance": true, "billing": "charge_automatically", "billing_reason": "subscription", "charge": "ch_5WybupUzcscclq", "closed": false, "currency": "gbp", "customer": valid_subscription_student.stripe_customer_id, "date": 1420193829, "description": nil, "discount": nil, "due_date": nil, "ending_balance": 0, "forgiven": false, "hosted_invoice_url": "https://pay.stripe.com/invoice/invst_0kScQzgfwvufrbPULAPttcBSCi", "invoice_pdf": "https://pay.stripe.com/invoice/invst_0kScQzgfwvufrbPULAPttcBSCi/pdf", "lines": {"data": [{"id": "sli_859339fd5ed203", "object": "line_item", "amount": 0, "currency": "gbp", "description": "Trial period for LearnSignal Test 267", "discountable": true, "livemode": false, "metadata": {}, "period": {"end": 1540807556, "start": 1540202756}, "plan": {"id": subscription_plan_gbp_m.stripe_guid, "object": "plan", "active": true, "aggregate_usage": nil, "amount": 999, "billing_scheme": "per_unit", "created": 1462284968, "currency": "gbp", "interval": "month", "interval_count": 1, "livemode": false, "metadata": {}, "nickname": nil, "product": "prod_BTuUwcCciIESD8", "tiers": nil, "tiers_mode": nil, "transform_usage": nil, "trial_period_days": 7, "usage_type": "licensed"}, "proration": false, "quantity": 1, "subscription": valid_subscription.stripe_guid, "subscription_item": "si_DpfdybeQdJlQfY", "type": "subscription"}], "has_more": false, "object": "list", "url": "/v1/invoices/in_5RLAdp7JkW1w6I/lines"}, "livemode": false, "metadata": {}, "next_payment_attempt": nil, "number": nil, "paid": false, "period_end": 1420193754, "period_start": 1417515354, "receipt_number": nil, "starting_balance": 0, "statement_descriptor": nil, "subscription": valid_subscription.stripe_guid, "subtotal": 500, "tax": nil, "tax_percent": nil, "total": 500, "webhooks_delivered_at": 1420193835}
          invoice_url = "https://api.stripe.com/v1/invoices/#{invoice.stripe_guid}"
          stub_invoice_get_request(invoice_url, invoice_response_body)



          subscription_url = "https://api.stripe.com/v1/subscriptions/#{valid_subscription.stripe_guid}"
          subscription = {      "id": valid_subscription.stripe_guid, "object": "subscription",
                                "billing": "charge_automatically", "status": "active",
                                "billing_cycle_anchor": 1540455078, "cancel_at_period_end": false,
                                "created": 1539850278, "current_period_end": 1540455078, "current_period_start": 1539850278,
                                "customer": valid_subscription_student.stripe_customer_id, "plan": {"livemode": false}}

          stub_subscription_get_request(subscription_url, subscription)


          post :create, post_request_body.to_json

          expect(StripeApiEvent.count).to eq(1)
          sae = StripeApiEvent.last
          expect(sae.processed).to eq(true)
          expect(sae.error).to eq(false)
          expect(sae.error_message).to eq(nil)
          valid_subscription.reload
          expect(valid_subscription.current_status).to eq('active')
        end

        it 'customer.subscription.deleted event' do
          post_request_body = {"id": "evt_00000000000003", "object": "event", "api_version": "2017-05-25", "created": 1496232624, "data": {"object": {"id": valid_subscription.stripe_guid, "object": "subscription", "application_fee_percent": nil, "cancel_at_period_end": false, "canceled_at": nil, "created": 1496232623, "current_period_end": 1498824623, "current_period_start": 1496232623, "customer": valid_subscription_student.stripe_customer_id, "discount": nil, "ended_at": nil, "items": {"object": "list", "data": [{"id": "si_00000000", "object": "subscription_item", "created": 1496232624, "plan": {"id": "s-basic", "object": "plan", "amount": 599, "created": 1494334156, "currency": "gbp", "interval": "month", "interval_count": 1, "livemode": false, "metadata": {}, "name": "S Basic", "statement_descriptor": nil, "trial_period_days": nil}, "quantity": 1}], "has_more": false, "total_count": 1, "url": ""}, "livemode": false, "metadata": {}, "plan": {"id": "s-basic", "object": "plan", "amount": 599, "created": 1494334156, "currency": "gbp", "interval": "month", "interval_count": 1, "livemode": false, "metadata": {}, "name": "S Basic", "statement_descriptor": nil, "trial_period_days": nil}, "quantity": 1, "start": 1496232623, "status": "active", "tax_percent": nil, "trial_end": nil, "trial_start": nil}}, "livemode": false, "pending_webhooks": 0, "request": "req_Al1inviVvNH7vG", "type": "customer.subscription.deleted"}

          event_url = 'https://api.stripe.com/v1/events/evt_00000000000003'
          stub_event_get_request(event_url, post_request_body)

          sources = {"id": "src_Do8swBcNDszFmc", "object": "source", "client_secret": "src_client_secret_Do8sRLByihYpru4LuNCGYP8L",
                     "created": 1539850277, "currency": "gbp", "flow": "receiver", "livemode": false, "status": "pending"
          }
          subscriptions = {"id": valid_subscription.stripe_guid, "object": "subscription", "livemode": false,
                           "current_period_end": 1540455078, "plan": {"id": subscription_plan_gbp_m.stripe_guid,
                                                                      "object": "plan", "active": true,
                                                                      "amount": 999, "livemode": false }, "status": "canceled"}

          get_response_body = {"id": valid_subscription_student.stripe_customer_id, "object": "customer", "account_balance": 0,
                               "invoice_prefix": "1C44D6D", "livemode": false,"default_source": "src_Do8swBcNDszFmc",
                               "sources": {"object": "list", "data": [], "has_more": false, "total_count": 0,
                                           "url": "/v1/customers/cus_Do8skFvJFlWtvy/sources"},
                               "subscriptions": {"object": "list","data": [subscriptions],"has_more": false,"total_count": 0,
                                                 "url": "/v1/customers/#{valid_subscription_student.stripe_customer_id}/subscriptions"}}

          customer_url = "https://api.stripe.com/v1/customers/#{valid_subscription_student.stripe_customer_id}"
          stub_customer_get_request(customer_url, get_response_body)

          subscription_url = "https://api.stripe.com/v1/customers/#{valid_subscription_student.stripe_customer_id}/subscriptions/#{valid_subscription.stripe_guid}"
          subscription = {      "id": valid_subscription.stripe_guid, "object": "subscription",
                                "billing": "charge_automatically", "status": "canceled",
                                "billing_cycle_anchor": 1540455078, "cancel_at_period_end": false,
                                "created": 1539850278, "current_period_end": 1540455078, "current_period_start": 1539850278,
                                "customer": valid_subscription_student.stripe_customer_id, "plan": {"livemode": false}}

          stub_subscription_get_request(subscription_url, subscription)

          post :create, post_request_body.to_json

          expect(StripeApiEvent.count).to eq(1)
          sae = StripeApiEvent.last
          expect(sae.processed).to eq(true)
          expect(sae.error).to eq(false)
          expect(sae.error_message).to eq(nil)
          valid_subscription.reload
          expect(valid_subscription.current_status).to eq('canceled')
        end


      it 'charge.succeeded event' do

        post_request_body = {"id": "evt_00000000000004", "object": "event", "api_version": "2017-05-25", "created": 1496232624, "data": {"object": {"id": "ch_21334nj453h", "object": "charge", "amount": 4999, "amount_refunded": 0, "application": nil, "application_fee": nil, "balance_transaction": "txn_DnMzeou1YFmJdC", "captured": false, "created": 1536859350, "currency": "gbp", "customer": valid_subscription_student.stripe_customer_id, "description": nil, "destination": nil, "dispute": nil, "failure_code": "expired_card", "failure_message": "Your card has expired.", "fraud_details": {}, "invoice": invoice.stripe_guid, "livemode": false, "metadata": {}, "on_behalf_of": nil, "order": nil, "outcome": {"network_status": "declined_by_network", "reason": "expired_card", "risk_level": "normal", "risk_score": 22, "seller_message": "The bank returned the decline code `expired_card`.", "type": "issuer_declined"}, "paid": false, "payment_intent": nil, "receipt_email": nil, "receipt_number": nil, "refunded": false, "refunds": {"object": "list", "data": [], "has_more": false, "total_count": 0, "url": "/v1/charges/ch_DbAsGRHpM5BaaY/refunds"}, "review": nil, "shipping": nil, "source": {"id": "guid_222", "object": "card", "address_city": nil, "address_country": nil, "address_line1": nil, "address_line1_check": nil, "address_line2": nil, "address_state": nil, "address_zip": nil, "address_zip_check": nil, "brand": "Visa", "country": "US", "customer": valid_subscription_student.stripe_customer_id, "cvc_check": nil, "dynamic_last4": nil, "exp_month": 8, "exp_year": 2018, "fingerprint": "2JyQfTIvakRtY5NA", "funding": "credit", "last4": "4242", "metadata": {}, "name": nil, "tokenization_method": nil}, "source_transfer": nil, "statement_descriptor": "LearnSignal", "status": "succeeded", "transfer_group": nil}}, "livemode": false, "pending_webhooks": 0, "request": "req_Al1inviVvNH7vG", "type": "charge.succeeded"}

        event_url = 'https://api.stripe.com/v1/events/evt_00000000000004'
        stub_event_get_request(event_url, post_request_body)

        post :create, post_request_body.to_json

        expect(StripeApiEvent.count).to eq(1)
        expect(Charge.count).to eq(2)
        sae = StripeApiEvent.last
        expect(sae.processed).to eq(true)
        expect(sae.error).to eq(false)
        expect(sae.error_message).to eq(nil)
        valid_subscription.reload
        expect(valid_subscription.current_status).to eq('active')
      end

      it 'charge.failed event' do
        post_request_body = {"id": "evt_00000000000005", "object": "event", "api_version": "2017-05-25", "created": 1496232624, "data": {"object": {"id": "ch_21334nj453h", "object": "charge", "amount": 4999, "amount_refunded": 0, "application": nil, "application_fee": nil, "balance_transaction": "txn_DnMzeou1YFmJdC", "captured": false, "created": 1536859350, "currency": "gbp", "customer": valid_subscription_student.stripe_customer_id, "description": nil, "destination": nil, "dispute": nil, "failure_code": "expired_card", "failure_message": "Your card has expired.", "fraud_details": {}, "invoice": invoice.stripe_guid, "livemode": false, "metadata": {}, "on_behalf_of": nil, "order": nil, "outcome": {"network_status": "declined_by_network", "reason": "expired_card", "risk_level": "normal", "risk_score": 22, "seller_message": "The bank returned the decline code `expired_card`.", "type": "issuer_declined"}, "paid": false, "payment_intent": nil, "receipt_email": nil, "receipt_number": nil, "refunded": false, "refunds": {"object": "list", "data": [], "has_more": false, "total_count": 0, "url": "/v1/charges/ch_DbAsGRHpM5BaaY/refunds"}, "review": nil, "shipping": nil, "source": {"id": "guid_222", "object": "card", "address_city": nil, "address_country": nil, "address_line1": nil, "address_line1_check": nil, "address_line2": nil, "address_state": nil, "address_zip": nil, "address_zip_check": nil, "brand": "Visa", "country": "US", "customer": valid_subscription_student.stripe_customer_id, "cvc_check": nil, "dynamic_last4": nil, "exp_month": 8, "exp_year": 2018, "fingerprint": "2JyQfTIvakRtY5NA", "funding": "credit", "last4": "4242", "metadata": {}, "name": nil, "tokenization_method": nil}, "source_transfer": nil, "statement_descriptor": "LearnSignal", "status": "succeeded", "transfer_group": nil}}, "livemode": false, "pending_webhooks": 0, "request": "req_Al1inviVvNH7vG", "type": "charge.failed"}

        event_url = 'https://api.stripe.com/v1/events/evt_00000000000005'
        stub_event_get_request(event_url, post_request_body)

        post :create, post_request_body.to_json

        expect(StripeApiEvent.count).to eq(1)
        expect(Charge.count).to eq(2)
        sae = StripeApiEvent.last
        expect(sae.processed).to eq(true)
        expect(sae.error).to eq(false)
        expect(sae.error_message).to eq(nil)
        valid_subscription.reload
        expect(valid_subscription.current_status).to eq('active')
      end

      it 'charge.refunded event' do
        post_request_body = {"id": "evt_00000000000006", "object": "event", "api_version": "2017-05-25", "created": 1496232624, "data": {"object": {"id": "ch_21334nj453h", "object": "charge", "amount": 4999, "amount_refunded": 0, "application": nil, "application_fee": nil, "balance_transaction": "txn_DnMzeou1YFmJdC", "captured": false, "created": 1536859350, "currency": "gbp", "customer": valid_subscription_student.stripe_customer_id, "description": nil, "destination": nil, "dispute": nil, "failure_code": "expired_card", "failure_message": "Your card has expired.", "fraud_details": {}, "invoice": invoice.stripe_guid, "livemode": false, "metadata": {}, "on_behalf_of": nil, "order": nil, "outcome": {"network_status": "declined_by_network", "reason": "expired_card", "risk_level": "normal", "risk_score": 22, "seller_message": "The bank returned the decline code `expired_card`.", "type": "issuer_declined"}, "paid": true, "payment_intent": nil, "receipt_email": nil, "receipt_number": nil, "refunded": true, "refunds": {"object": "list", "data": [], "has_more": false, "total_count": 0, "url": "/v1/charges/ch_DbAsGRHpM5BaaY/refunds"}, "review": nil, "shipping": nil, "source": {"id": "guid_222", "object": "card", "address_city": nil, "address_country": nil, "address_line1": nil, "address_line1_check": nil, "address_line2": nil, "address_state": nil, "address_zip": nil, "address_zip_check": nil, "brand": "Visa", "country": "US", "customer": valid_subscription_student.stripe_customer_id, "cvc_check": nil, "dynamic_last4": nil, "exp_month": 8, "exp_year": 2018, "fingerprint": "2JyQfTIvakRtY5NA", "funding": "credit", "last4": "4242", "metadata": {}, "name": nil, "tokenization_method": nil}, "source_transfer": nil, "statement_descriptor": "LearnSignal", "status": "succeeded", "transfer_group": nil}}, "livemode": false, "pending_webhooks": 0, "request": "req_Al1inviVvNH7vG", "type": "charge.refunded"}

        event_url = 'https://api.stripe.com/v1/events/evt_00000000000006'
        stub_event_get_request(event_url, post_request_body)

        post :create, post_request_body.to_json

        expect(StripeApiEvent.count).to eq(1)
        expect(Charge.count).to eq(1)
        sae = StripeApiEvent.last
        expect(sae.processed).to eq(true)
        expect(sae.error).to eq(false)
        expect(sae.error_message).to eq(nil)
        charge.reload
        expect(charge.refunded).to eq(true)
      end

      it 'coupon.updated event' do
        post_request_body = {"id": "evt_00000000000007", "object": "event", "api_version": "2017-05-25", "created": 1496232624, "data": {"object": {"id": coupon.code, "object": "coupon", "amount_off": nil, "created": 1540202756, "currency": nil, "duration": "repeating", "duration_in_months": 3, "livemode": false, "max_redemptions": nil, "metadata": {}, "name": "25.5% off", "percent_off": 25.5, "redeem_by": nil, "times_redeemed": 0, "valid": false}}, "livemode": false, "pending_webhooks": 0, "request": "req_Al1inviVvNH7vG", "type": "coupon.updated"}

        event_url = 'https://api.stripe.com/v1/events/evt_00000000000007'
        stub_event_get_request(event_url, post_request_body)

        url = "https://api.stripe.com/v1/coupons/#{coupon.code}"
        response_body = {"id": coupon.code, "object": "coupon", "amount_off": nil, "created": 1540202756, "currency": nil, "duration": "repeating", "duration_in_months": 3, "livemode": false, "max_redemptions": nil, "metadata": {}, "name": "25.5% off", "percent_off": 25.5, "redeem_by": nil, "times_redeemed": 0, "valid": false}
        stub_coupon_get_request(url, response_body)

        post :create, post_request_body.to_json

        expect(StripeApiEvent.count).to eq(1)
        expect(Coupon.count).to eq(1)
        sae = StripeApiEvent.last
        expect(sae.processed).to eq(true)
        expect(sae.error).to eq(false)
        expect(sae.error_message).to eq(nil)
        coupon.reload
        expect(coupon.active).to eq(false)
      end

    end

      describe 'invoice with invalid data' do

        it 'should not process invoice.created event if user with given GUID does not exist' do

          post_request_body = {"id": "evt_00000000000008", "object": "event", "api_version": "2017-05-25", "created": 1326853478, "data": {"object": {"id": "in_1APVed2eZvKYlo2CP6dsoJTo", "object": "invoice", "amount_due": 599, "application_fee": nil, "attempt_count": 1, "attempted": true, "charge": "ch_1APVed2eZvKYlo2C1QNH6jru", "closed": true, "currency": "gbp", "customer": "cu_0000000", "date": 1496232623, "description": nil, "discount": nil, "ending_balance": 0, "forgiven": false, "lines": {"data": [{"id": valid_subscription.stripe_guid, "object": "line_item", "amount": 599, "currency": "gbp", "description": nil, "discountable": true, "livemode": true, "metadata": {}, "period": {"start": 1498824623, "end": 1501503023}, "plan": {"id": subscription_plan_gbp_m.stripe_guid, "object": "plan", "amount": 999, "created": 1496222010, "currency": "gbp", "interval": "month", "interval_count": 1, "livemode": false, "metadata": {}, "name": subscription_plan_gbp_m.name, "statement_descriptor": nil, "trial_period_days": nil}, "proration": false, "quantity": 1, "subscription": nil, "subscription_item": "si_1APVed2eZvKYlo2C387JnMRE", "type": "subscription"}], "total_count": 1, "object": "list", "url": "/v1/invoices/in_1APVed2eZvKYlo2CP6dsoJTo/lines"}, "livemode": false, "metadata": {}, "next_payment_attempt": nil, "paid": true, "period_end": 1496232623, "period_start": 1496232623, "receipt_number": nil, "starting_balance": 0, "statement_descriptor": nil, "subscription": valid_subscription.stripe_guid, "subtotal": 599, "tax": nil, "tax_percent": nil, "total": 599, "webhooks_delivered_at": 1496232630}}, "livemode": false, "pending_webhooks": 1, "request": "req_Al1inviVvNH7df", "type": "invoice.created"}


          url = 'https://api.stripe.com/v1/events/evt_00000000000008'
          stub_event_get_request(url, post_request_body)

          post :create, post_request_body.to_json

          expect(StripeApiEvent.count).to eq(1)
          sae = StripeApiEvent.last
          expect(sae.processed).to eq(false)
          expect(sae.error).to eq(true)
          expect(sae.error_message).to eq("Error creating invoice")
        end

        it 'should not process invoice.created event if subscription with given GUID does not exist' do

          post_request_body = {"id": "evt_00000000000009", "object": "event", "api_version": "2017-05-25", "created": 1326853478, "data": {"object": {"id": "in_1APVed2eZvKYlo2CP6dsoJTo", "object": "invoice", "amount_due": 599, "application_fee": nil, "attempt_count": 1, "attempted": true, "charge": "ch_1APVed2eZvKYlo2C1QNH6jru", "closed": true, "currency": "gbp", "customer": "cu_0000000", "date": 1496232623, "description": nil, "discount": nil, "ending_balance": 0, "forgiven": false, "lines": {"data": [{"id": valid_subscription.stripe_guid, "object": "line_item", "amount": 599, "currency": "gbp", "description": nil, "discountable": true, "livemode": true, "metadata": {}, "period": {"start": 1498824623, "end": 1501503023}, "plan": {"id": subscription_plan_gbp_m.stripe_guid, "object": "plan", "amount": 999, "created": 1496222010, "currency": "gbp", "interval": "month", "interval_count": 1, "livemode": false, "metadata": {}, "name": "sub_000000000", "statement_descriptor": nil, "trial_period_days": nil}, "proration": false, "quantity": 1, "subscription": nil, "subscription_item": "si_1APVed2eZvKYlo2C387JnMRE", "type": "subscription"}], "total_count": 1, "object": "list", "url": "/v1/invoices/in_1APVed2eZvKYlo2CP6dsoJTo/lines"}, "livemode": false, "metadata": {}, "next_payment_attempt": nil, "paid": true, "period_end": 1496232623, "period_start": 1496232623, "receipt_number": nil, "starting_balance": 0, "statement_descriptor": nil, "subscription": "sub_000000000", "subtotal": 599, "tax": nil, "tax_percent": nil, "total": 599, "webhooks_delivered_at": 1496232630}}, "livemode": false, "pending_webhooks": 1, "request": "req_Al1inviVvNH7df", "type": "invoice.created"}


          url = 'https://api.stripe.com/v1/events/evt_00000000000009'
          stub_event_get_request(url, post_request_body)

          post :create, post_request_body.to_json

          expect(StripeApiEvent.count).to eq(1)
          sae = StripeApiEvent.last
          expect(sae.processed).to eq(false)
          expect(sae.error).to eq(true)
          expect(sae.error_message).to eq("Error creating invoice")
        end

        it 'should not process invoice.created event if subscription plan from invoice line item with given GUID does not exist' do

          post_request_body = {"id": "evt_00000000000010", "object": "event", "api_version": "2017-05-25", "created": 1326853478, "data": {"object": {"id": "in_1APVed2eZvKYlo2CP6dsoJTo", "object": "invoice", "amount_due": 599, "application_fee": nil, "attempt_count": 1, "attempted": true, "charge": "ch_1APVed2eZvKYlo2C1QNH6jru", "closed": true, "currency": "gbp", "customer": "cu_0000000", "date": 1496232623, "description": nil, "discount": nil, "ending_balance": 0, "forgiven": false, "lines": {"data": [{"id": valid_subscription.stripe_guid, "object": "line_item", "amount": 599, "currency": "gbp", "description": nil, "discountable": true, "livemode": true, "metadata": {}, "period": {"start": 1498824623, "end": 1501503023}, "plan": {"id": "plan_0000000", "object": "plan", "amount": 999, "created": 1496222010, "currency": "gbp", "interval": "month", "interval_count": 1, "livemode": false, "metadata": {}, "name": "sub_000000000", "statement_descriptor": nil, "trial_period_days": nil}, "proration": false, "quantity": 1, "subscription": nil, "subscription_item": "si_1APVed2eZvKYlo2C387JnMRE", "type": "subscription"}], "total_count": 1, "object": "list", "url": "/v1/invoices/in_1APVed2eZvKYlo2CP6dsoJTo/lines"}, "livemode": false, "metadata": {}, "next_payment_attempt": nil, "paid": true, "period_end": 1496232623, "period_start": 1496232623, "receipt_number": nil, "starting_balance": 0, "statement_descriptor": nil, "subscription": "sub_000000000", "subtotal": 599, "tax": nil, "tax_percent": nil, "total": 599, "webhooks_delivered_at": 1496232630}}, "livemode": false, "pending_webhooks": 1, "request": "req_Al1inviVvNH7df", "type": "invoice.created"}


          url = 'https://api.stripe.com/v1/events/evt_00000000000010'
          stub_event_get_request(url, post_request_body)

          post :create, post_request_body.to_json

          expect(StripeApiEvent.count).to eq(1)
          sae = StripeApiEvent.last
          expect(sae.processed).to eq(false)
          expect(sae.error).to eq(true)
          expect(sae.error_message).to eq("Error creating invoice")
        end

      end

    end

  end

end
