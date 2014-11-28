require 'rails_helper'

RSpec.describe CourseModuleJumboQuizzesController, type: :routing do
  describe 'routing' do

    it 'routes to #new' do
      expect(get: '/course_module_jumbo_quizzes/new').to route_to('course_module_jumbo_quizzes#new')
    end

    it 'routes to #edit' do
      expect(get: '/course_module_jumbo_quizzes/1/edit').to route_to('course_module_jumbo_quizzes#edit', id: '1')
    end

    it 'routes to #create' do
      expect(post: '/course_module_jumbo_quizzes').to route_to('course_module_jumbo_quizzes#create')
    end

    it 'routes to #update' do
      expect(put: '/course_module_jumbo_quizzes/1').to route_to('course_module_jumbo_quizzes#update', id: '1')
    end

  end
end
