# == Schema Information
#
# Table name: subject_courses
#
#  id                                      :integer          not null, primary key
#  name                                    :string
#  name_url                                :string
#  sorting_order                           :integer
#  active                                  :boolean          default(FALSE), not null
#  cme_count                               :integer
#  video_count                             :integer
#  quiz_count                              :integer
#  question_count                          :integer
#  description                             :text
#  short_description                       :string
#  created_at                              :datetime         not null
#  updated_at                              :datetime         not null
#  best_possible_first_attempt_score       :float
#  default_number_of_possible_exam_answers :integer
#  total_video_duration                    :float            default(0.0)
#  destroyed_at                            :datetime
#  email_content                           :text
#  external_url_name                       :string
#  external_url                            :string
#  exam_body_id                            :integer
#  survey_url                              :string
#  group_id                                :integer
#  quiz_pass_rate                          :integer
#  total_estimated_time_in_seconds         :integer
#

FactoryGirl.define do
  factory :subject_course do
    sequence(:name)      { |x| "Subject Course #{x}" }
    sequence(:name_url)  { |x| "subject-course-#{x}" }
    sorting_order 1
    active false
    cme_count 1
    video_count 1
    quiz_count 1
    question_count 1
    description "MyText"
    short_description "MyString"
    email_content "MyString"
    default_number_of_possible_exam_answers 4
    quiz_pass_rate 10
    group_id 1

    factory :active_subject_course do
      active                       true
    end

    factory :inactive_subject_course do
      active                       false
    end
  end

end
