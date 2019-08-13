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

    describe '#get_customer' do
      it 'calls #retrieve on Stripe::Customer with the passed in Stripe ID' do
        expect(Stripe::Customer).to receive(:retrieve).with('stripe_test_id')

        subject.get_customer('stripe_test_id')
      end
    end
  end

  # SUBSCRIPTIONS ==============================================================

  context 'subscriptions' do
    describe '#change_plan' do
      it 'changes the plan'
    end

    describe '#create_and_return_subscription' do
      it 'creates and returns a subscription on Stripe'
    end

    describe '#get_subscription' do
      it 'return a subscription from Stripe' do
        expect(Stripe::Subscription).to receive(:retrieve).with(id: 'sub_id')

        subject.get_subscription('sub_id')
      end
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
