require 'rails_helper'

RSpec.describe ExamSectionsController, type: :routing do
  describe 'routing' do

    it 'routes to #index' do
      expect(get: '/exam_sections').to route_to('exam_sections#index')
    end

    it 'routes to #new' do
      expect(get: '/exam_sections/new').to route_to('exam_sections#new')
    end

    it 'routes to #index' do
      expect(post: '/exam_sections/filter').to route_to('exam_sections#index')
    end

    it 'routes to #show' do
      expect(get: '/exam_sections/1').to route_to('exam_sections#show', id: '1')
    end

    it 'routes to #edit' do
      expect(get: '/exam_sections/1/edit').to route_to('exam_sections#edit', id: '1')
    end

    it 'routes to #create' do
      expect(post: '/exam_sections').to route_to('exam_sections#create')
    end

    it 'routes to #update' do
      expect(put: '/exam_sections/1').to route_to('exam_sections#update', id: '1')
    end

    it 'routes to #reorder' do
      expect(post: '/exam_sections/reorder').to route_to('exam_sections#reorder')
    end

    it 'routes to #destroy' do
      expect(delete: '/exam_sections/1').to route_to('exam_sections#destroy', id: '1')
    end

  end
end
