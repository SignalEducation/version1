# == Schema Information
#
# Table name: course_tutor_details
#
#  id                :integer          not null, primary key
#  subject_course_id :integer
#  user_id           :integer
#  sorting_order     :integer
#  title             :string
#  created_at        :datetime         not null
#  updated_at        :datetime         not null
#

require 'rails_helper'

RSpec.describe CourseTutorDetailsController, type: :routing do
  describe 'routing' do

    it 'routes to #index' do
      expect(get: '/course_tutor_details').to route_to('course_tutor_details#index')
    end

    it 'routes to #new' do
      expect(get: '/course_tutor_details/new').to route_to('course_tutor_details#new')
    end

    it 'routes to #show' do
      expect(get: '/course_tutor_details/1').to route_to('course_tutor_details#show', id: '1')
    end

    it 'routes to #edit' do
      expect(get: '/course_tutor_details/1/edit').to route_to('course_tutor_details#edit', id: '1')
    end

    it 'routes to #create' do
      expect(post: '/course_tutor_details').to route_to('course_tutor_details#create')
    end

    it 'routes to #update' do
      expect(put: '/course_tutor_details/1').to route_to('course_tutor_details#update', id: '1')
    end

    it 'routes to #reorder' do
      expect(post: '/course_tutor_details/reorder').to route_to('course_tutor_details#reorder')
    end
    # todo move this to routes.rb ABOVE the resource:
    # post 'course_tutor_details/reorder', to: 'course_tutor_details#reorder'

    it 'routes to #destroy' do
      expect(delete: '/course_tutor_details/1').to route_to('course_tutor_details#destroy', id: '1')
    end

  end
end
