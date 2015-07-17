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
      expect(get: 'library/exam_level').to route_to('library#show', exam_level_name_url: 'exam_level')
    end

    it 'routes to #show' do
      expect(get: 'library/exam_level/exam_section').to route_to('library#show', exam_level_name_url: 'exam_level', exam_section_name_url: 'exam_section')
    end

  end
end
