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

    it 'routes to #preview_course' do
      expect(get: '/library/group_2/course_2/preview').to route_to('library#preview_course', group_name_url: 'group_2', subject_course_name_url: 'course_2')
    end

    it 'routes to #subscribe' do
      expect(post: '/subscribe').to route_to('library#subscribe')
    end

    xit 'routes to #cert' do
      expect(get: '/completion_cert/1').to route_to('library#cert', id: 1)
    end

  end
end
