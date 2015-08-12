require 'rails_helper'

RSpec.describe CorporateGroupsController, type: :routing do
  describe 'routing' do

    it 'routes to #index' do
      expect(get: '/corporate_groups').to route_to('corporate_groups#index')
    end

    it 'routes to #new' do
      expect(get: '/corporate_groups/new').to route_to('corporate_groups#new')
    end

    it 'routes to #edit' do
      expect(get: '/corporate_groups/1/edit').to route_to('corporate_groups#edit', id: '1')
    end

    it 'routes to #create' do
      expect(post: '/corporate_groups').to route_to('corporate_groups#create')
    end

    it 'routes to #update' do
      expect(put: '/corporate_groups/1').to route_to('corporate_groups#update', id: '1')
    end

    it 'routes to #destroy' do
      expect(delete: '/corporate_groups/1').to route_to('corporate_groups#destroy', id: '1')
    end

  end
end
