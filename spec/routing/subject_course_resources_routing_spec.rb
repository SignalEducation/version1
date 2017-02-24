# == Schema Information
#
# Table name: subject_course_resources
#
#  id                       :integer          not null, primary key
#  name                     :string
#  subject_course_id        :integer
#  description              :text
#  created_at               :datetime         not null
#  updated_at               :datetime         not null
#  file_upload_file_name    :string
#  file_upload_content_type :string
#  file_upload_file_size    :integer
#  file_upload_updated_at   :datetime
#

require 'rails_helper'

RSpec.describe SubjectCourseResourcesController, type: :routing do
  describe 'routing' do

    it 'routes to #index' do
      expect(get: '/subject_course_resources').to route_to('subject_course_resources#index')
    end

    it 'routes to #new' do
      expect(get: '/subject_course_resources/new').to route_to('subject_course_resources#new')
    end

    it 'routes to #show' do
      expect(get: '/subject_course_resources/1').to route_to('subject_course_resources#show', id: '1')
    end

    it 'routes to #edit' do
      expect(get: '/subject_course_resources/1/edit').to route_to('subject_course_resources#edit', id: '1')
    end

    it 'routes to #create' do
      expect(post: '/subject_course_resources').to route_to('subject_course_resources#create')
    end

    it 'routes to #update' do
      expect(put: '/subject_course_resources/1').to route_to('subject_course_resources#update', id: '1')
    end


    it 'routes to #destroy' do
      expect(delete: '/subject_course_resources/1').to route_to('subject_course_resources#destroy', id: '1')
    end

  end
end
