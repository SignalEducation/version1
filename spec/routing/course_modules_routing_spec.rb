require 'rails_helper'

RSpec.describe CourseModulesController, type: :routing do
  describe 'routing' do

    it 'routes to #index' do
      expect(get: '/course_modules').to route_to('course_modules#index')
    end

    it 'routes to #create' do
      expect(post: '/course_modules').to route_to('course_modules#create')
    end

    it 'routes to #update' do
      expect(put: '/course_modules/1').to route_to('course_modules#update', id: '1')
    end

    it 'routes to #reorder' do
      expect(post: '/course_modules/reorder').to route_to('course_modules#reorder')
    end

    it 'routes to #destroy' do
      expect(delete: '/course_modules/1').to route_to('course_modules#destroy', id: '1')
    end

  end
end
