require 'rails_helper'

RSpec.describe LibraryController, type: :routing do
  describe 'routing' do

    it 'routes to #library' do
      expect(get: '/library').to route_to('library#index')
    end

    it 'routes to #group_show' do
      expect(get: 'library/group_1').to route_to('library#group_show', group_name_url: 'group_1')
    end

    it 'routes to #course_show' do
      expect(get: '/library/group_1/course_1').to route_to('library#course_show', group_name_url: 'group_1', subject_course_name_url: 'course_1')
    end

  end
end
