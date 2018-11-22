require 'rails_helper'

describe PaypalWebhookService, type: :service do
  let(:paypal_sale_completed) { JSON.parse(File.read(Rails.root.join('spec/fixtures/paypal/webhook_payment_sale_completed.json').to_s)) }
  let(:hook_service) { PaypalWebhookService.new(webhook_request, paypal_sale_completed) }

  # INSTANCE METHODS ###########################################################

  describe '#process' do
    it 'calls #trigger_payment_actions' do
      expect(hook_service).to receive(:trigger_payment_actions)

      hook_service.process
    end
  end

  describe '#record_webhook' do
    it 'creates a PaypalWebhook record' do
      expect { 
        hook_service.record_webhook 
      }.to change { PaypalWebhook.count }.from(0).to(1)
    end
  end

  describe '#valid?' do
    it 'calls #verify on an PayPal::SDK::REST::DataTypes::WebhookEvent' do
      expect(PayPal::SDK::REST::DataTypes::WebhookEvent).to receive(:verify)

      hook_service.valid?
    end
  end

  # PRIVATE METHODS ############################################################

  describe '#trigger_payment_actions' do
    describe 'BILLING.SUBSCRIPTION.CANCELLED' do
      let(:billing_sub_cancelled) { JSON.parse(File.read(Rails.root.join('spec/fixtures/paypal/webhook_billing_subscription_cancelled.json').to_s)) }
      let(:hook_service) { PaypalWebhookService.new(webhook_request, billing_sub_cancelled) }

      before :each do
        hook_service.record_webhook
      end

      it 'calls #process_subscription_cancelled on the PaypalWebhook object' do
        expect_any_instance_of(PaypalWebhook).to receive(:process_subscription_cancelled)

        hook_service.send(:trigger_payment_actions)
      end
    end

    describe 'PAYMENT.SALE.COMPLETED' do
      before :each do
        hook_service.record_webhook
      end

      it 'calls #process_subscription_cancelled on the PaypalWebhook object' do
        expect_any_instance_of(PaypalWebhook).to receive(:process_sale_completed)

        hook_service.send(:trigger_payment_actions)
      end
    end

    describe 'PAYMENT.SALE.DENIED' do
      let(:payment_sale_denied) { JSON.parse(File.read(Rails.root.join('spec/fixtures/paypal/webhook_payment_sale_denied.json').to_s)) }
      let(:hook_service) { PaypalWebhookService.new(webhook_request, payment_sale_denied) }

      before :each do
        hook_service.record_webhook
      end

      it 'calls #process_sale_denied on the PaypalWebhook object' do
        expect_any_instance_of(PaypalWebhook).to receive(:process_sale_denied)

        hook_service.send(:trigger_payment_actions)
      end
    end
  end

  # def trigger_payment_actions
  #   case @webhook.event_type
  #   when 'BILLING.SUBSCRIPTION.CREATED'
  #     Rails.logger.info "PAYPAL WEBHOOK: TRIGGERED SUBSCRIPTION.CREATED ACTION"
  #   when 'BILLING.SUBSCRIPTION.CANCELLED'
  #     @webhook.process_subscription_cancelled
  #   when 'BILLING.SUBSCRIPTION.RE-ACTIVATED'
  #     # do stuff
  #   when 'BILLING.SUBSCRIPTION.SUSPENDED'
  #     # do stuff
  #   when 'BILLING.SUBSCRIPTION.UPDATED'
  #     # do stuff
  #   when 'PAYMENT.SALE.COMPLETED'
  #     @webhook.process_sale_completed
  #   when 'PAYMENT.SALE.DENIED'
  #     @webhook.process_sale_denied
  #   end
  # end

  describe '#transmission_id' do
    it 'returns the header request transmission_id' do
      expect(hook_service.send(:transmission_id)).to eq webhook_request.headers["Paypal-Transmission-Id"]
    end
  end

  describe '#actual_signature' do
    it 'returns the header request transmission_signature' do
      expect(hook_service.send(:actual_signature)).to eq webhook_request.headers["Paypal-Transmission-Sig"]
    end
  end

  describe '#auth_algo' do
    it 'returns the header request auth_algo' do
      expect(hook_service.send(:auth_algo)).to eq webhook_request.headers["Paypal-Auth-Algo"]
    end
  end

  describe '#cert_url' do
    it 'returns the header request cert_url' do
      expect(hook_service.send(:cert_url)).to eq webhook_request.headers["Paypal-Cert-Url"]
    end
  end

  describe '#timestamp' do
    it 'returns the header request timestamp' do
      expect(hook_service.send(:timestamp)).to eq webhook_request.headers["Paypal-Transmission-Time"]
    end
  end

  def webhook_request
    double(
      headers: {
        "Paypal-Transmission-Id" => "dfb3be50-fd74-11e4-8bf3-77339302725b",
        "Paypal-Transmission-Sig" => "thy4/U002quzxFavHPwbfJGcc46E8rc5jzgyeafWm5mICTBdY/8rl7WJpn8JA0GKA+oDTPsSruqusw+XXg5RLAP7ip53Euh9Xu3UbUhQFX7UgwzE2FeYoY6lyRMiiiQLzy9BvHfIzNIVhPad4KnC339dr6y2l+mN8ALgI4GCdIh3/SoJO5wE64Bh/ueWtt8EVuvsvXfda2Le5a2TrOI9vLEzsm9GS79hAR/5oLexNz8UiZr045Mr5ObroH4w4oNfmkTaDk9Rj0G19uvISs5QzgmBpauKr7Nw++JI0pr/v5mFctQkoWJSGfBGzPRXawrvIIVHQ9Wer48GR2g9ZiApWg==",
        "Paypal-Auth-Algo" => "sha256",
        "Paypal-Cert-Url" => "https://api.sandbox.paypal.com/v1/notifications/certs/CERT-360caa42-fca2a594-a5cafa77",
        "Paypal-Transmission-Time" => "2015-05-18T15:45:13Z"
      }
    )
  end
end