require 'rails_helper'

describe PaypalWebhookService, type: :service do
  let(:paypal_sale_completed) { JSON.parse(File.read(Rails.root.join('spec/fixtures/paypal/webhook_payment_sale_completed.json').to_s)) }
  let(:hook_service) { PaypalWebhookService.new }

  # INSTANCE METHODS ###########################################################

  describe '#record_webhook' do
    it 'creates a PaypalWebhook record' do
      expect {
        hook_service.record_webhook(paypal_sale_completed)
      }.to change { PaypalWebhook.count }.from(0).to(1)
    end
  end

  describe '#process_webhook' do
    it 'calls #trigger_payment_actions' do
      expect(hook_service).to receive(:trigger_payment_actions)

      hook_service.process_webhook
    end
  end

  describe '#reprocess_webhook' do
    let(:hook) { create(:paypal_webhook, guid: 'webhook_guid') }

    it 'reprocesses the PayPal webhook'
    it 'calls get on the PayPal WebhookEvent object' do
      expect(PayPal::SDK::REST::WebhookEvent).to receive(:get).with('webhook_guid').and_return(paypal_sale_completed)

      hook_service.reprocess_webhook(hook)
    end

    it 'calls #trigger_payment_actions' do
      allow(PayPal::SDK::REST::WebhookEvent).to receive(:get).with('webhook_guid').and_return(paypal_sale_completed)
      expect(hook_service).to receive(:trigger_payment_actions)

      hook_service.reprocess_webhook(hook)
    end

    it 'rescues PayPal::SDK::Core::Exceptions::ResourceNotFound exceptions' do
      allow(PayPal::SDK::REST::WebhookEvent).to receive(:get).with('webhook_guid').and_raise(PayPal::SDK::Core::Exceptions::ResourceNotFound.new('paypal error'))
      expect(Rails.logger).to receive(:info).with("Webhook information no longer available for PaypalWebhook #{hook.id}")

      hook_service.reprocess_webhook(hook)
    end
  end

  # PRIVATE METHODS ############################################################

  describe '#trigger_payment_actions' do
    describe 'BILLING.SUBSCRIPTION.CANCELLED' do
      let(:billing_sub_cancelled) {
        JSON.parse(
          File.read(
            Rails.root.join('spec/fixtures/paypal/webhook_billing_subscription_cancelled.json').to_s
          )
        )
      }
      let(:hook_service) { PaypalWebhookService.new }

      before :each do
        hook_service.record_webhook(billing_sub_cancelled)
      end

      it 'calls #process_subscription_cancelled on the PaypalWebhook object' do
        expect_any_instance_of(PaypalWebhook).to(
          receive(:process_subscription_cancelled)
        )

        hook_service.send(:trigger_payment_actions)
      end
    end

    describe 'PAYMENT.SALE.COMPLETED' do
      before :each do
        hook_service.record_webhook(paypal_sale_completed)
      end

      it 'calls #process_subscription_cancelled on the PaypalWebhook object' do
        expect_any_instance_of(PaypalWebhook).to receive(:process_sale_completed)

        hook_service.send(:trigger_payment_actions)
      end
    end

    describe 'PAYMENT.SALE.DENIED' do
      let(:payment_sale_denied) {
        JSON.parse(
          File.read(
            Rails.root.join('spec/fixtures/paypal/webhook_payment_sale_denied.json').to_s
          )
        )
      }
      let(:hook_service) { PaypalWebhookService.new }

      before :each do
        hook_service.record_webhook(payment_sale_denied)
      end

      it 'calls #process_sale_denied on the PaypalWebhook object' do
        expect_any_instance_of(PaypalWebhook).to receive(:process_sale_denied)

        hook_service.send(:trigger_payment_actions)
      end
    end
  end
end
