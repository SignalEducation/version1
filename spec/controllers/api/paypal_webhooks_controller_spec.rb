require 'rails_helper'

describe Api::PaypalWebhooksController, type: :controller do

  describe 'POST #create' do
    describe 'with a valid Webhook' do
      let(:webhook_params) {
        {
          "id": "evt_00000000000001", "event_type": "event", "api_version": "2017-05-25", "created": 1326853478, "data": {"object": {"id": "in_1APVed2eZvKYlo2CP6dsoJTo", "object": "invoice", "amount_due": 599, "application_fee": nil, "attempt_count": 1, "attempted": true, "charge": "ch_1APVed2eZvKYlo2C1QNH6jru", "closed": true, "currency": "gbp", "customer": 'fdasfdsf', "date": 1496232623, "description": nil, "discount": nil, "ending_balance": 0, "forgiven": false, "lines": {"data": [{"id": 'afdsfafsdf', "object": "line_item", "amount": 599, "currency": "gbp", "description": nil, "discountable": true, "livemode": true, "metadata": {}, "period": {"start": 1498824623, "end": 1501503023}, "plan": {"id": 'dsfdsafaf', "object": "plan", "amount": 999, "created": 1496222010, "currency": "gbp", "interval": "month", "interval_count": 1, "livemode": false, "metadata": {}, "name": 'afdsafdasfdsaf', "statement_descriptor": nil, "trial_period_days": nil}, "proration": false, "quantity": 1, "subscription": nil, "subscription_item": "si_1APVed2eZvKYlo2C387JnMRE", "type": "subscription"}], "total_count": 1, "object": "list", "url": "/v1/invoices/in_1APVed2eZvKYlo2CP6dsoJTo/lines"}, "livemode": false, "metadata": {}, "next_payment_attempt": nil, "paid": true, "period_end": 1496232623, "period_start": 1496232623, "receipt_number": nil, "starting_balance": 0, "statement_descriptor": nil, "subscription": 'asfdasfsaf', "subtotal": 599, "tax": nil, "tax_percent": nil, "total": 599, "webhooks_delivered_at": 1496232630}}, "livemode": false, "pending_webhooks": 1, "request": "req_Al1inviVvNH7df", "type": "invoice.created"
        }
      }

      it 'creates a new instance of PaypalWebhookService' do
        expect(PaypalWebhookService).to receive(:new)

        post :create, webhook_params, headers: webhook_headers
      end

      it 'saves the webhook' do
        expect {
          post :create, webhook_params, headers: webhook_headers
        }.to change{ PaypalWebhook.count }.from(0).to(1)
      end

      it 'processes the webhook' do
        expect_any_instance_of(PaypalWebhookService).to receive(:process)

        post :create, webhook_params, headers: webhook_headers        
      end
    end

    describe 'with an in-valid Webhook' do
      let(:webhook_params) {
        { "id": "evt_00000000000001" }
      }

      it 'creates a new instance of PaypalWebhookService' do
        expect(PaypalWebhookService).to receive(:new)

        post :create, webhook_params, headers: webhook_headers
      end

      it 'does not save the webhook' do
        expect {
          post :create, webhook_params, headers: webhook_headers
        }.not_to change{ PaypalWebhook.count }
      end

      it 'does not processes the webhook' do
        expect_any_instance_of(PaypalWebhookService).not_to receive(:process)

        post :create, webhook_params, headers: webhook_headers        
      end
    end
  end

  def webhook_headers
    {
      "Paypal-Transmission-Id" => "dfb3be50-fd74-11e4-8bf3-77339302725b",
      "Paypal-Transmission-Sig" => "thy4/U002quzxFavHPwbfJGcc46E8rc5jzgyeafWm5mICTBdY/8rl7WJpn8JA0GKA+oDTPsSruqusw+XXg5RLAP7ip53Euh9Xu3UbUhQFX7UgwzE2FeYoY6lyRMiiiQLzy9BvHfIzNIVhPad4KnC339dr6y2l+mN8ALgI4GCdIh3/SoJO5wE64Bh/ueWtt8EVuvsvXfda2Le5a2TrOI9vLEzsm9GS79hAR/5oLexNz8UiZr045Mr5ObroH4w4oNfmkTaDk9Rj0G19uvISs5QzgmBpauKr7Nw++JI0pr/v5mFctQkoWJSGfBGzPRXawrvIIVHQ9Wer48GR2g9ZiApWg==",
      "Paypal-Auth-Algo" => "sha256",
      "Paypal-Cert-Url" => "https://api.sandbox.paypal.com/v1/notifications/certs/CERT-360caa42-fca2a594-a5cafa77",
      "Paypal-Transmission-Time" => "2015-05-18T15:45:13Z"
    }
  end
end
