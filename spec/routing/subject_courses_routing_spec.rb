# == Schema Information
#
# Table name: subject_courses
#
#  id                                      :integer          not null, primary key
#  name                                    :string
#  name_url                                :string
#  sorting_order                           :integer
#  active                                  :boolean          default(FALSE), not null
#  live                                    :boolean          default(FALSE), not null
#  wistia_guid                             :string
#  tutor_id                                :integer
#  cme_count                               :integer
#  video_count                             :integer
#  quiz_count                              :integer
#  question_count                          :integer
#  description                             :text
#  short_description                       :string
#  mailchimp_guid                          :string
#  created_at                              :datetime         not null
#  updated_at                              :datetime         not null
#  best_possible_first_attempt_score       :float
#  default_number_of_possible_exam_answers :integer
#  restricted                              :boolean          default(FALSE), not null
#  corporate_customer_id                   :integer
#  total_video_duration                    :float            default(0.0)
#  destroyed_at                            :datetime
#  is_cpd                                  :boolean          default(FALSE)
#  cpd_hours                               :float
#  cpd_pass_rate                           :integer
#  live_date                               :datetime
#  certificate                             :boolean          default(FALSE), not null
#  hotjar_guid                             :string
#  enrollment_option                       :boolean          default(FALSE)
#  subject_course_category_id              :integer
#  email_content                           :text
#  external_url_name                       :string
#  external_url                            :string
#

require 'rails_helper'

RSpec.describe SubjectCoursesController, type: :routing do
  describe 'routing' do

    it 'routes to #index' do
      expect(get: '/subject_courses').to route_to('subject_courses#index')
    end

    it 'routes to #new' do
      expect(get: '/subject_courses/new').to route_to('subject_courses#new')
    end

    it 'routes to #show' do
      expect(get: '/subject_courses/1').to route_to('subject_courses#show', id: '1')
    end

    it 'routes to #edit' do
      expect(get: '/subject_courses/1/edit').to route_to('subject_courses#edit', id: '1')
    end

    it 'routes to #create' do
      expect(post: '/subject_courses').to route_to('subject_courses#create')
    end

    it 'routes to #update' do
      expect(put: '/subject_courses/1').to route_to('subject_courses#update', id: '1')
    end

    it 'routes to #reorder' do
      expect(post: '/subject_courses/reorder').to route_to('subject_courses#reorder')
    end
    # todo move this to routes.rb ABOVE the resource:
    # post 'subject_courses/reorder', to: 'subject_courses#reorder'

    it 'routes to #destroy' do
      expect(delete: '/subject_courses/1').to route_to('subject_courses#destroy', id: '1')
    end

  end
end
