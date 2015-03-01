require 'rails_helper'

RSpec.describe SubscriptionPaymentCardsController, type: :routing do
  describe 'routing' do

    it 'routes to #create' do
      expect(post: '/subscription_payment_cards').to route_to('subscription_payment_cards#create')
    end

    it 'routes to #update' do
      expect(put: '/subscription_payment_cards/1').to route_to('subscription_payment_cards#update', id: '1')
    end

  end
end
