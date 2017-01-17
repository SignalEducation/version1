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
#  subject_course_category_id              :integer
#  email_content                           :text
#  external_url_name                       :string
#  external_url                            :string
#  exam_body_id                            :integer
#

FactoryGirl.define do
  factory :subject_course do
    sequence(:name)      { |x| "Subject Course #{x}" }
    sequence(:name_url)  { |x| "subject-course-#{x}" }
    sorting_order 1
    active false
    live false
    sequence(:wistia_guid)       {|n| "dfgsdfg#{n}"}
    tutor_id 1
    cme_count 1
    video_count 1
    quiz_count 1
    question_count 1
    description "MyText"
    short_description "MyString"
    sequence(:mailchimp_guid)       {|n| "dfgsdfg#{n}"}
    default_number_of_possible_exam_answers 1
    subject_course_category_id 1

    factory :active_subject_course do
      active                       true
      live                         true
    end

    factory :inactive_subject_course do
      active                       false
    end
  end

end
