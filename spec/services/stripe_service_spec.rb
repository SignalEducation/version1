require 'rails_helper'

describe StripeService, type: :service do

  # CUSTOMERS ==================================================================
  context 'customers' do
    describe '#create_customer!' do
      let(:user) { create(:user) }

      it 'creates the customer on Stripe' do
        expect(Stripe::Customer).to receive(:create).and_return(double(id: 'stripe_test_id'))

        subject.create_customer!(user)
      end

      it 'updates the user with the Stripe customer id' do
        allow(Stripe::Customer).to receive(:create).and_return(double(id: 'stripe_test_id'))

        expect { subject.create_customer!(user) }.to change { user.stripe_customer_id }.from(nil).to('stripe_test_id')
      end
    end
  end

  describe '#create_purchase' do
    let(:order) { build_stubbed(:order) }
    let(:stripe_intent) {
      double(customer: 'cus_12345', id: 'in_12345', client_secret: 'cs_123456')
    }

    it 'creates a Stripe PaymentIntent' do
      expect(subject).to receive(:create_payment_intent).with(order).and_return(stripe_intent)
      allow(subject).to receive(:set_order_status).and_return(order)

      subject.create_purchase(order)
    end

    it 'assigns the correct attributes to an order' do
      expect(order).to receive(:assign_attributes).with(
        hash_including({
          stripe_customer_id: 'cus_12345',
          stripe_payment_intent_id: 'in_12345',
          stripe_client_secret: 'cs_123456'
        })
      )
      allow(subject).to receive(:create_payment_intent).and_return(stripe_intent)
      allow(subject).to receive(:set_order_status).and_return(order)

      subject.create_purchase(order)
    end

    it 'returns an order' do
      allow(subject).to receive(:create_payment_intent).and_return(stripe_intent)
      allow(subject).to receive(:set_order_status).and_return(order)

      expect(subject.create_purchase(order)).to be_kind_of Order
    end
  end

  describe '#set_order_status' do
    let(:order) { create(:order) }

    describe 'for 3DS payments' do
      let(:stripe_intent) {
        double(status: 'requires_action', next_action: double(type: 'use_stripe_sdk'))
      }

      it 'sets the status of the Order based on 3DS requirements (from Stripe)' do
        expect(order.state).to eq 'pending'

        subject.send(:set_order_status, stripe_intent, order)

        expect(order.state).to eq 'pending_3d_secure'
      end
    end

    describe 'for non-3DS payments' do
      let(:failed_stripe_intent) { double(status: 'failed') }
      let(:successful_stripe_intent) { double(status: 'succeeded') }

      it 'sets the relevant Order status for failed PaymentIntents' do
        expect(order.state).to eq 'pending'

        subject.send(:set_order_status, failed_stripe_intent, order)

        expect(order.state).to eq 'errored'
      end

      it 'sets the relevant Order status for successful PaymentIntents' do
        expect(order.state).to eq 'pending'

        subject.send(:set_order_status, successful_stripe_intent, order)

        expect(order.state).to eq 'pending'
      end
    end 
  end

  describe '#confirm_purchase' do
    let(:order) { build_stubbed(:order) }    

    it 'calls transition[confirm_3d_secure] if the intent is successful' do
      intent = double(status: 'succeeded')
      allow(Stripe::PaymentIntent).to receive(:confirm).and_return(intent)
      expect(order).to receive(:confirm_3d_secure)

      order.confirm_payment_intent
    end

    it 'raises a LearnSignal::PaymentError if we get any Stripe::CardError' do
      allow_any_instance_of(Stripe::PaymentIntent).to(
        receive(:confirm).and_raise(Stripe::CardError)
      )

      expect{ order.confirm_purchase }.to raise_error{ Learnsignal::PaymentError }
    end
  end

  # PRODUCTS ===================================================================

  describe '#create_product' do
    let(:product) { create(:product, stripe_guid: nil, stripe_sku_guid: nil) }
    let(:stripe_product) { double(livemode: true, id: 'prod_12344') }
    let(:stripe_sku) { double(id: 'sku_123456') }

    it 'calls #create_stripe_product with the correct args' do
      allow(Stripe::SKU).to receive(:create).and_return(stripe_sku)
      expect(subject).to receive(:create_stripe_product).with(product).
        and_return(stripe_product)

      subject.create_product(product)
    end

    it 'calls #create_stripe_sku with the correct args' do
      allow(subject).to(
        receive(:create_stripe_product).and_return(stripe_product)
      )
      expect(subject).to(
        receive(:create_stripe_sku).with(product, stripe_product).
        and_return(stripe_sku)
      )

      subject.create_product(product)
    end

    it 'updates the product stripe_guid' do
      allow(Stripe::SKU).to receive(:create).and_return(stripe_sku)
      allow(subject).to(
        receive(:create_stripe_product).and_return(stripe_product)
      )

      expect { subject.create_product(product) }.to(
        change { product.stripe_guid }.from(nil).to('prod_12344')
      )
    end

    it 'updates the product stripe_sku_guid' do
      allow(Stripe::SKU).to receive(:create).and_return(stripe_sku)
      allow(subject).to(
        receive(:create_stripe_product).and_return(stripe_product)
      )

      expect { subject.create_product(product) }.to(
        change { product.stripe_sku_guid }.from(nil).to('sku_123456')
      )
    end
  end

  describe '#update_product' do
    let(:product) { create(:product, stripe_guid: 'prod_12344') }
    let(:stripe_product) { double(livemode: true, id: 'prod_12344') }

    it 'calls #retrieve on the Stripe product' do
      allow(stripe_product).to receive(:name=)
      allow(stripe_product).to receive(:active=)
      allow(stripe_product).to receive(:save)
      expect(Stripe::Product).to receive(:retrieve).with(id: stripe_product.id).
        and_return(stripe_product)

      subject.update_product(product)
    end

    it 'updates the product' do
      allow(Stripe::Product).to receive(:retrieve).with(id: stripe_product.id).
        and_return(stripe_product)
      expect(stripe_product).to receive(:name=)
      expect(stripe_product).to receive(:active=)
      expect(stripe_product).to receive(:save)

      subject.update_product(product)
    end
  end

  # INVOICES ==============================================================

  describe '#get_invoice' do
    it 'return a invoice from Stripe' do
      expect(Stripe::Invoice).to receive(:retrieve).with(id: 'invoice_id', expand: ['payment_intent'])

      subject.get_invoice('invoice_id')
    end
  end
end
