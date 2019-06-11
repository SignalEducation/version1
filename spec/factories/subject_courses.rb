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
#  description                             :text
#  created_at                              :datetime         not null
#  updated_at                              :datetime         not null
#  default_number_of_possible_exam_answers :integer
#  destroyed_at                            :datetime
#  exam_body_id                            :integer
#  survey_url                              :string
#  group_id                                :integer
#  quiz_pass_rate                          :integer
#  background_image_file_name              :string
#  background_image_content_type           :string
#  background_image_file_size              :integer
#  background_image_updated_at             :datetime
#  preview                                 :boolean          default(FALSE)
#  computer_based                          :boolean          default(FALSE)
#  highlight_colour                        :string           default("#ef475d")
#  category_label                          :string
#  icon_label                              :string
#  constructed_response_count              :integer          default(0)
#  completion_cme_count                    :integer
#  release_date                            :date
#  seo_title                               :string
#  seo_description                         :string
#

FactoryBot.define do
  factory :subject_course do
    sequence(:name)      { |x| "Subject Course #{x}" }
    sequence(:name_url)  { |x| "subject-course-#{x}" }
    sorting_order { 1 }
    active { false }
    cme_count { 1 }
    video_count { 1 }
    quiz_count { 1 }
    # question_count { 1 }
    description { "MyText" }
    # short_description { "MyString" }
    # email_content { "MyString" }
    default_number_of_possible_exam_answers { 4 }
    quiz_pass_rate { 10 }
    group
    survey_url { 'SurveyURL' }
    exam_body
    category_label 'Category'
    icon_label 'Icon'

    factory :active_subject_course do
      active                       { true }
      preview                       { false }
    end

    factory :inactive_subject_course do
      active                       { false }
    end

    factory :preview_subject_course do
      active                       { true }
      preview                       { true }
    end
  end
end
