require 'rails_helper'

RSpec.describe SubjectCoursesController, type: :routing do
  describe 'routing' do

    it 'routes to #index' do
      expect(get: '/subject_courses').to route_to('subject_courses#index')
    end

    it 'routes to #new' do
      expect(get: '/subject_courses/new').to route_to('subject_courses#new')
    end

    it 'routes to #show' do
      expect(get: '/subject_courses/1').to route_to('subject_courses#show', id: '1')
    end

    it 'routes to #edit' do
      expect(get: '/subject_courses/1/edit').to route_to('subject_courses#edit', id: '1')
    end

    it 'routes to #create' do
      expect(post: '/subject_courses').to route_to('subject_courses#create')
    end

    it 'routes to #update' do
      expect(put: '/subject_courses/1').to route_to('subject_courses#update', id: '1')
    end

    it 'routes to #reorder' do
      expect(post: '/subject_courses/reorder').to route_to('subject_courses#reorder')
    end
    # todo move this to routes.rb ABOVE the resource:
    # post 'subject_courses/reorder', to: 'subject_courses#reorder'

    it 'routes to #destroy' do
      expect(delete: '/subject_courses/1').to route_to('subject_courses#destroy', id: '1')
    end

  end
end
