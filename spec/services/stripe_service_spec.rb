require 'rails_helper'

describe StripeService, type: :service do

  # CUSTOMERS ==================================================================
  context 'custumers' do
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
