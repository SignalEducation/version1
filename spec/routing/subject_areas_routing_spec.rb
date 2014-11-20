require 'rails_helper'

RSpec.describe SubjectAreasController, type: :routing do
  describe 'routing' do

    it 'routes to #index' do
      expect(get: '/subject_areas').to route_to('subject_areas#index')
    end

    it 'routes to #new' do
      expect(get: '/subject_areas/new').to route_to('subject_areas#new')
    end

    it 'routes to #show' do
      expect(get: '/subject_areas/1').to route_to('subject_areas#show', id: '1')
    end

    it 'routes to #edit' do
      expect(get: '/subject_areas/1/edit').to route_to('subject_areas#edit', id: '1')
    end

    it 'routes to #create' do
      expect(post: '/subject_areas').to route_to('subject_areas#create')
    end

    it 'routes to #update' do
      expect(put: '/subject_areas/1').to route_to('subject_areas#update', id: '1')
    end

    it 'routes to #reorder' do
      expect(post: '/subject_areas/reorder').to route_to('subject_areas#reorder')
    end

    it 'routes to #destroy' do
      expect(delete: '/subject_areas/1').to route_to('subject_areas#destroy', id: '1')
    end

  end
end
