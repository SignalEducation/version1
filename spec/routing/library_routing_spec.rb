require 'rails_helper'

RSpec.describe LibraryController, type: :routing do
  describe 'routing' do

    it 'routes to #subscription_groups' do
      expect(get: '/subscription_groups').to route_to('library#group_index')
    end

    it 'routes to #group_show' do
      expect(get: 'subscription_group/group_1').to route_to('library#group_show', group_name_url: 'group_1')
    end

    it 'routes to #course_show' do
      expect(get: '/subscription_course/course_1').to route_to('library#course_show', subject_course_name_url: 'course_1')
    end

    it 'routes to #diploma_show' do
      expect(get: '/product_course/diploma_1').to route_to('library#diploma_show', subject_course_name_url: 'diploma_1')
    end

    it 'routes to #subscribe' do
      expect(post: '/subscribe').to route_to('library#subscribe')
    end

    xit 'routes to #cert' do
      expect(get: '/completion_cert/1').to route_to('library#cert', id: 1)
    end

  end
end
