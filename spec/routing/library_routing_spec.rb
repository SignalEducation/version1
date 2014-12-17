require 'rails_helper'

RSpec.describe LibraryController, type: :routing do
  describe 'routing' do

    it 'routes to #index' do
      expect(get: '/library').to route_to('library#show')
    end

    it 'routes to #show' do
      expect(get: '/library/1').to route_to('library#show', subject_area_name_url: '1')
    end

    # special routes

    it 'routes to #show' do
      expect(get: '/library/subject_area/institution/qualification/exam_level/exam_section').to route_to('library#show', subject_area_name_url: 'subject_area', institution_name_url: 'institution', qualification_name_url: 'qualification', exam_level_name_url: 'exam_level', exam_section_name_url: 'exam_section')
    end

    it 'routes to #show' do
      expect(get: '/library/subject_area/institution/qualification/exam_level').to route_to('library#show', subject_area_name_url: 'subject_area', institution_name_url: 'institution', qualification_name_url: 'qualification', exam_level_name_url: 'exam_level')
    end

    it 'routes to #show' do
      expect(get: '/library/subject_area/institution/qualification').to route_to('library#show', subject_area_name_url: 'subject_area', institution_name_url: 'institution', qualification_name_url: 'qualification')
    end

    it 'routes to #show' do
      expect(get: '/library/subject_area/institution').to route_to('library#show', subject_area_name_url: 'subject_area', institution_name_url: 'institution')
    end

    it 'routes to #show' do
      expect(get: '/library/subject_area/').to route_to('library#show', subject_area_name_url: 'subject_area')
    end

    it 'routes to #show' do
      expect(get: '/library').to route_to('library#show')
    end

  end
end
