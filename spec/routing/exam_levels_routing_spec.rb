require 'rails_helper'

RSpec.describe ExamLevelsController, type: :routing do
  describe 'routing' do

    it 'routes to #index' do
      expect(get: '/exam_levels').to route_to('exam_levels#index')
    end

    it 'routes to #index' do
      expect(post: '/exam_levels/filter').to route_to('exam_levels#index')
    end

    it 'routes to #new' do
      expect(get: '/exam_levels/new').to route_to('exam_levels#new')
    end

    it 'routes to #show' do
      expect(get: '/exam_levels/1').to route_to('exam_levels#show', id: '1')
    end

    it 'routes to #edit' do
      expect(get: '/exam_levels/1/edit').to route_to('exam_levels#edit', id: '1')
    end

    it 'routes to #create' do
      expect(post: '/exam_levels').to route_to('exam_levels#create')
    end

    it 'routes to #update' do
      expect(put: '/exam_levels/1').to route_to('exam_levels#update', id: '1')
    end

    it 'routes to #reorder' do
      expect(post: '/exam_levels/reorder').to route_to('exam_levels#reorder')
    end

    it 'routes to #destroy' do
      expect(delete: '/exam_levels/1').to route_to('exam_levels#destroy', id: '1')
    end

  end
end
