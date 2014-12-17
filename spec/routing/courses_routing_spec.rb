require 'rails_helper'

RSpec.describe CoursesController, type: :routing do
  describe 'routing' do

    it 'routes to #show' do
      expect(get: '/courses/1').to route_to('courses#show', id: '1')
    end

    it 'routes to #create' do
      expect(post: '/courses').to route_to('courses#create')
    end

    # special routes

    it 'routes to #show' do
      expect(get: '/courses/study_area/institution/exam_level/exam_section/course_module').to route_to('courses#show', study_area_name_url: 'study_area', institution_name_url: 'institution', exam_level_name_url: 'exam_level', exam_section_name_url: 'exam_section', course_module_name_url: 'course_module')
    end

    it 'routes to #show' do
      expect(get: '/courses/study_area/institution/exam_level/exam_section/course_module/course_module_element').to route_to('courses#show', study_area_name_url: 'study_area', institution_name_url: 'institution', exam_level_name_url: 'exam_level', exam_section_name_url: 'exam_section', course_module_name_url: 'course_module', course_module_element_name_url: 'course_module_element')
    end

  end
end
