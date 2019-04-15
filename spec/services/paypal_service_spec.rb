require 'rails_helper'

describe PaypalService, type: :service do

  describe '#create_purchase' do

    let(:order) { build_stubbed(:order) }

    it 'calls CREATE on an instance of PayPal::SDK::REST::DataTypes::Agreement::Plan' do
      # allow_any_instance_of(PayPal::SDK::REST::DataTypes::Plan).to receive(:update)
      # expect_any_instance_of(PayPal::SDK::REST::DataTypes::Plan).to receive(:create)

      subject.create_purchase(order)
    end

    it 'calls #update_subscription_plan' do
      allow_any_instance_of(PayPal::SDK::REST::DataTypes::Plan).to receive(:update)
      allow_any_instance_of(PayPal::SDK::REST::DataTypes::Plan).to receive(:create)
      expect(subject).to receive(:update_subscription_plan).with(subscription_plan, anything)

      subject.create_plan(subscription_plan)
    end

    it 'calls #update_subscription_plan_state' do
      allow_any_instance_of(PayPal::SDK::REST::DataTypes::Plan).to receive(:update).and_return(true)
      allow_any_instance_of(PayPal::SDK::REST::DataTypes::Plan).to receive(:create)
      expect(subject).to receive(:update_subscription_plan_state).with(subscription_plan, 'ACTIVE')

      subject.create_plan(subscription_plan)
    end
  end

  describe '#execute_payment' do
  end

  # PRIVATE METHODS ############################################################

  describe '#payment_attributes' do
    let(:order) { create(:order) }

    it 'returns the correct hash' do
      expect(subject.send(:payment_attributes, order))
        .to eq (
          {
            intent: 'sale',
            payer: {
              payment_method: 'paypal'
            },
            redirect_urls: {
              return_url: "https://staging.learnsignal.com/en/orders/#{order.id}/execute?payment_processor=paypal",
              cancel_url: "https://staging.learnsignal.com/en/order/new/#{order.id}?flash=It+seems+you+cancelled+your+order+on+Paypal.+Still+want+to+purchase%3F"
            },
            transactions: [
              {
                item_list: {
                  items: [
                    {
                      name: order.product.name,
                      price: order.product.price.to_s,
                      currency: order.product.currency.iso_code,
                      quantity: 1 
                    }
                  ]
                },
                amount: {
                  total: order.product.price.to_s,
                  currency: order.product.currency.iso_code
                },
                description: "Mock exam purchase - #{order.product.name}" 
              }
            ]
          }
        )
    end
  end
end