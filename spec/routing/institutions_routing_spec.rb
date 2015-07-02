require 'rails_helper'

RSpec.describe InstitutionsController, type: :routing do
  describe 'routing' do

    it 'routes to #index' do
      expect(get: '/institutions').to route_to('institutions#index')
    end

    it 'routes to #index' do
      expect(get: '/institutions/filter/123').to route_to('institutions#index', subject_area_url: '123')
    end

    it 'routes to #new' do
      expect(get: '/institutions/new').to route_to('institutions#new')
    end

    it 'routes to #show' do
      expect(get: '/institutions/1').to route_to('institutions#show', id: '1')
    end

    it 'routes to #edit' do
      expect(get: '/institutions/1/edit').to route_to('institutions#edit', id: '1')
    end

    it 'routes to #create' do
      expect(post: '/institutions').to route_to('institutions#create')
    end

    it 'routes to #update' do
      expect(put: '/institutions/1').to route_to('institutions#update', id: '1')
    end

    it 'routes to #reorder' do
      expect(post: '/institutions/reorder').to route_to('institutions#reorder')
    end

    it 'routes to #destroy' do
      expect(delete: '/institutions/1').to route_to('institutions#destroy', id: '1')
    end

  end
end
