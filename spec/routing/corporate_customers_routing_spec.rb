require 'rails_helper'

RSpec.describe CorporateCustomersController, type: :routing do
  describe 'routing' do

    it 'routes to #index' do
      expect(get: '/corporate_customers').to route_to('corporate_customers#index')
    end

    it 'routes to #new' do
      expect(get: '/corporate_customers/new').to route_to('corporate_customers#new')
    end

    it 'routes to #show' do
      expect(get: '/corporate_customers/1').to route_to('corporate_customers#show', id: '1')
    end

    it 'routes to #edit' do
      expect(get: '/corporate_customers/1/edit').to route_to('corporate_customers#edit', id: '1')
    end

    it 'routes to #create' do
      expect(post: '/corporate_customers').to route_to('corporate_customers#create')
    end

    it 'routes to #update' do
      expect(put: '/corporate_customers/1').to route_to('corporate_customers#update', id: '1')
    end

    it 'routes to #destroy' do
      expect(delete: '/corporate_customers/1').to route_to('corporate_customers#destroy', id: '1')
    end

  end
end
