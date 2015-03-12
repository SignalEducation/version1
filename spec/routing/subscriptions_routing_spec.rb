require 'rails_helper'

RSpec.describe SubscriptionsController, type: :routing do
  describe 'routing' do

    it 'routes to #create' do
      expect(post: '/subscriptions/').to route_to('subscriptions#create')
    end

    it 'routes to #update' do
      expect(put: '/subscriptions/1').to route_to('subscriptions#update', id: '1')
    end

    it 'routes to #destroy' do
      expect(delete: '/subscriptions/1').to route_to('subscriptions#destroy', id: '1')
    end

  end
end
