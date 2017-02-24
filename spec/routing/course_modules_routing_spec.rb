# == Schema Information
#
# Table name: course_modules
#
#  id                        :integer          not null, primary key
#  name                      :string
#  name_url                  :string
#  description               :text
#  sorting_order             :integer
#  estimated_time_in_seconds :integer
#  active                    :boolean          default(FALSE), not null
#  created_at                :datetime
#  updated_at                :datetime
#  cme_count                 :integer          default(0)
#  seo_description           :string
#  seo_no_index              :boolean          default(FALSE)
#  destroyed_at              :datetime
#  number_of_questions       :integer          default(0)
#  subject_course_id         :integer
#  video_duration            :float            default(0.0)
#  video_count               :integer          default(0)
#  quiz_count                :integer          default(0)
#  highlight_colour          :string
#  tuition                   :boolean          default(FALSE)
#  test                      :boolean          default(FALSE)
#  revision                  :boolean          default(FALSE)
#  discourse_topic_id        :integer
#

require 'rails_helper'

RSpec.describe CourseModulesController, type: :routing do
  describe 'routing' do

    it 'routes to #index' do
      expect(get: '/course_modules').to route_to('course_modules#index')
    end

    it 'routes to #create' do
      expect(post: '/course_modules').to route_to('course_modules#create')
    end

    it 'routes to #update' do
      expect(put: '/course_modules/1').to route_to('course_modules#update', id: '1')
    end

    it 'routes to #reorder' do
      expect(post: '/course_modules/reorder').to route_to('course_modules#reorder')
    end

    it 'routes to #destroy' do
      expect(delete: '/course_modules/1').to route_to('course_modules#destroy', id: '1')
    end

  end
end
