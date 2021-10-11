require 'rails_helper'

describe PaypalService, type: :service do

  describe '#create_purchase' do
    let(:order) { build_stubbed(:order) }
    let(:payment_dbl) {
      double(
        'Payment',
        id: 'payment_FDAF343DFDA',
        links: [double( rel: 'approval_url', href: 'https://example.com/approval' )],
        state: 'PENDING'
      )
    }

    before :each do
      allow(PayPal::SDK::REST::DataTypes::Payment).to(receive(:new).and_return(payment_dbl))
      allow_any_instance_of(PaypalService).to receive(:payment_resources_id).and_return(nil)
      # allow(PaypalService).to(receive(:payment_resources_id).and_return(nil))
    end

    it 'calls CREATE on an instance of Payment and returns the order object' do
      expect(payment_dbl).to(receive(:create).and_return(true))

      expect(subject.create_purchase(order)).to be_instance_of(Order)
    end

    it 'updates the order with the correct attributes' do
      allow(payment_dbl).to(
        receive(:create).and_return(true)
      )
      expect(order.paypal_guid).to be_nil
      expect(order.paypal_approval_url).to be_nil
      expect(order.paypal_status).to be_nil

      subject.create_purchase(order)

      expect(order.paypal_guid).not_to be_nil
      expect(order.paypal_approval_url).not_to be_nil
      expect(order.paypal_status).not_to be_nil
    end

    it 'raises a Learnsignal::PaymentError if the payment is not created successfully' do
      allow(payment_dbl).to(
        receive(:create).and_return(false)
      )

      expect { subject.create_purchase(order) }.to raise_error(Learnsignal::PaymentError)
    end

    it 'catches any exceptions thrown by Paypal PayPal::SDK::Core::Exceptions::ServerError' do
      allow(payment_dbl).to(
        receive(:create).and_raise(PayPal::SDK::Core::Exceptions::ServerError.new('error'))
      )

      expect { subject.create_purchase(order) }.to raise_error(Learnsignal::PaymentError)
    end
  end

  describe '#execute_payment' do
    let(:gbp)   { create(:gbp) }
    let(:payment_dbl) {
      double(
        'Payment',
        id: 'payment_FDAF343DFDA',
        links: [double( rel: 'approval_url', href: 'https://example.com/approval' )],
        state: 'COMPLETED'
      )
    }
    let(:order) {
      create(
        :order,
        paypal_guid: payment_dbl.id,
        paypal_status: 'PENDING',
        paypal_approval_url: 'https://example.com/approval',
        stripe_order_payment_data: { currency: gbp.iso_code }
      )
    }

    before :each do
      allow(PayPal::SDK::REST::DataTypes::Payment).to(receive(:find).and_return(payment_dbl))
      allow(order).to receive(:execute_order_completion)
      allow_any_instance_of(PaypalService).to receive(:payment_resources_id).and_return(nil)
    end

    it 'ensures the paypal ID matches the paypal_guid of the order' do
      expect {
        subject.execute_payment(order, 'different_id', 'payer_id')
      }.to raise_error(Learnsignal::PaymentError)

      expect(order.state).to eq 'errored'
    end

    it 'calls EXECUTE on an instance of Payment' do
      expect(payment_dbl).to(
        receive(:execute).and_return(true)
      )

      subject.execute_payment(order, order.paypal_guid, 'payer_id')
    end

    it 'updates the state and paypal_status of the order' do
      expect(order.state).to eq 'pending'
      expect(order.paypal_status).to eq 'PENDING'
      allow(payment_dbl).to(
        receive(:execute).and_return(true)
      )

      subject.execute_payment(order, order.paypal_guid, 'payer_id')

      expect(order.state).to eq 'completed'
      expect(order.paypal_status).to eq 'COMPLETED'
    end

    it 'raises an error if the PayPal execute call fails' do
      allow(payment_dbl).to(
        receive(:execute).and_return(false)
      )

      expect {
        subject.execute_payment(order, order.paypal_guid, 'payer_id')
      }.to raise_error(Learnsignal::PaymentError)
      expect(order.state).to eq 'errored'
    end

    it 'catches any exceptions thrown by Paypal PayPal::SDK::Core::Exceptions::ServerError' do
      allow(payment_dbl).to(
        receive(:execute).and_raise(PayPal::SDK::Core::Exceptions::ServerError.new('error'))
      )

      expect {
        subject.execute_payment(order, order.paypal_guid, 'payer_id')
      }.to raise_error(Learnsignal::PaymentError)
    end
  end

  # PRIVATE METHODS ############################################################

  describe '#payment_attributes' do
    let(:gbp)       { create(:gbp) }
    let(:new_order) { create(:order, stripe_order_payment_data: { currency: gbp.iso_code }) }

    it 'returns the correct hash' do
      expect(subject.send(:payment_attributes, new_order))
        .to eq (
          {
            intent: 'sale',
            payer: {
              payment_method: 'paypal'
            },
            redirect_urls: {
              return_url: "https://staging-app.learnsignal.com/orders/#{new_order.id}/execute?payment_processor=paypal",
              cancel_url: "https://staging-app.learnsignal.com/products/#{new_order.product_id}/orders/new?flash=It+seems+you+cancelled+your+order+on+Paypal.+Still+want+to+purchase%3F"
            },
            transactions: [
              {
                item_list: {
                  items: [
                    {
                      name: new_order.product.name,
                      price: new_order.product.price.to_s,
                      currency: new_order.product.currency.iso_code,
                      quantity: 1
                    }
                  ]
                },
                amount: {
                  total: new_order.product.price.to_s,
                  currency: new_order.product.currency.iso_code
                },
                description: "Mock exam purchase - #{new_order.product.name}"
              }
            ]
          }
        )
    end
  end
end
