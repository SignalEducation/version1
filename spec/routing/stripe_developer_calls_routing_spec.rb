require 'rails_helper'

RSpec.describe StripeDeveloperCallsController, type: :routing do
  describe 'routing' do

    it 'routes to #index' do
      expect(get: '/stripe_developer_calls').to route_to('stripe_developer_calls#index')
    end

    it 'routes to #new' do
      expect(get: '/stripe_developer_calls/new').to route_to('stripe_developer_calls#new')
    end

    it 'routes to #show' do
      expect(get: '/stripe_developer_calls/1').to route_to('stripe_developer_calls#show', id: '1')
    end

    it 'routes to #edit' do
      expect(get: '/stripe_developer_calls/1/edit').to route_to('stripe_developer_calls#edit', id: '1')
    end

    it 'routes to #create' do
      expect(post: '/stripe_developer_calls').to route_to('stripe_developer_calls#create')
    end

    it 'routes to #update' do
      expect(put: '/stripe_developer_calls/1').to route_to('stripe_developer_calls#update', id: '1')
    end


    it 'routes to #destroy' do
      expect(delete: '/stripe_developer_calls/1').to route_to('stripe_developer_calls#destroy', id: '1')
    end

  end
end
