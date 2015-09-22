require 'rails_helper'

RSpec.describe LibraryController, type: :routing do
  describe 'routing' do

    it 'routes to #index' do
      expect(get: '/library').to route_to('library#index')
    end

    it 'routes to #show' do
      expect(post: '/subscribe').to route_to('library#subscribe')
    end

    # special routes

    it 'routes to #show' do
      expect(get: 'library/subject_course').to route_to('library#show', subject_course_name_url: 'subject_course')
    end

  end
end
