require 'rails_helper'

RSpec.describe CourseModuleElementsController, type: :routing do
  describe 'routing' do

    it 'routes to #show' do
      expect(get: '/course_module_elements/1').to route_to('course_module_elements#show', id: '1')
    end

    it 'routes to #new' do
      expect(get: '/course_module_elements/new').to route_to('course_module_elements#new')
    end

    it 'routes to #edit' do
      expect(get: '/course_module_elements/1/edit').to route_to('course_module_elements#edit', id: '1')
    end

    it 'routes to #create' do
      expect(post: '/course_module_elements').to route_to('course_module_elements#create')
    end

    it 'routes to #update' do
      expect(put: '/course_module_elements/1').to route_to('course_module_elements#update', id: '1')
    end

    it 'routes to #reorder' do
      expect(post: '/course_module_elements/reorder').to route_to('course_module_elements#reorder')
    end

    it 'routes to #destroy' do
      expect(delete: '/course_module_elements/1').to route_to('course_module_elements#destroy', id: '1')
    end

  end
end
