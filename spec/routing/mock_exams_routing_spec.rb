# == Schema Information
#
# Table name: mock_exams
#
#  id                       :integer          not null, primary key
#  subject_course_id        :integer
#  product_id               :integer
#  name                     :string
#  sorting_order            :integer
#  created_at               :datetime         not null
#  updated_at               :datetime         not null
#  file_file_name           :string
#  file_content_type        :string
#  file_file_size           :integer
#  file_updated_at          :datetime
#  cover_image_file_name    :string
#  cover_image_content_type :string
#  cover_image_file_size    :integer
#  cover_image_updated_at   :datetime
#

require 'rails_helper'

RSpec.describe MockExamsController, type: :routing do
  describe 'routing' do

    it 'routes to #index' do
      expect(get: '/mock_exams').to route_to('mock_exams#index')
    end

    it 'routes to #new' do
      expect(get: '/mock_exams/new').to route_to('mock_exams#new')
    end

    it 'routes to #edit' do
      expect(get: '/mock_exams/1/edit').to route_to('mock_exams#edit', id: '1')
    end

    it 'routes to #create' do
      expect(post: '/mock_exams').to route_to('mock_exams#create')
    end

    it 'routes to #update' do
      expect(put: '/mock_exams/1').to route_to('mock_exams#update', id: '1')
    end

    it 'routes to #reorder' do
      expect(post: '/mock_exams/reorder').to route_to('mock_exams#reorder')
    end

    it 'routes to #destroy' do
      expect(delete: '/mock_exams/1').to route_to('mock_exams#destroy', id: '1')
    end

  end
end
