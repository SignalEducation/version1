require 'rails_helper'

describe Api::PaypalWebhooksController, type: :controller do

  describe 'POST #create' do
    describe 'with a valid Webhook' do
      let(:webhook_params) { 
        JSON.parse(
          File.read(
            Rails.root.join('spec/fixtures/paypal/webhook_payment_sale_completed.json').to_s
          )
        )
      }

      xit 'creates a new instance of PaypalWebhookService' do
        expect(PaypalWebhookService).to receive(:new)

        post :create, webhook_params, headers: webhook_headers
      end

      xit 'saves the webhook' do
        expect {
          post :create, webhook_params, headers: webhook_headers
        }.to change{ PaypalWebhook.count }.from(0).to(1)
      end

      xit 'processes the webhook' do
        expect_any_instance_of(PaypalWebhookService).to receive(:process)

        post :create, webhook_params, headers: webhook_headers        
      end
    end

    describe 'with an in-valid Webhook' do
      let(:webhook_params) {
        { "id": "evt_00000000000001" }
      }

      xit 'creates a new instance of PaypalWebhookService' do
        expect(PaypalWebhookService).to receive(:new)

        post :create, webhook_params, headers: webhook_headers
      end

      xit 'does not save the webhook' do
        expect {
          post :create, webhook_params, headers: webhook_headers
        }.not_to change{ PaypalWebhook.count }
      end

      xit 'does not processes the webhook' do
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
