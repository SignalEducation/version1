# == Schema Information
#
# Table name: courses
#
#  id                                      :integer          not null, primary key
#  name                                    :string
#  name_url                                :string
#  sorting_order                           :integer
#  active                                  :boolean          default("false"), not null
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
#  preview                                 :boolean          default("false")
#  computer_based                          :boolean          default("false")
#  highlight_colour                        :string           default("#ef475d")
#  category_label                          :string
#  icon_label                              :string
#  constructed_response_count              :integer          default("0")
#  completion_cme_count                    :integer
#  release_date                            :date
#  seo_title                               :string
#  seo_description                         :string
#  has_correction_packs                    :boolean          default("false")
#  short_description                       :text
#  on_welcome_page                         :boolean          default("false")
#  unit_label                              :string
#  level_id                                :integer
#  accredible_group_id                     :integer
#

FactoryBot.define do
  factory :course do
    sequence(:name)                         { |n| "#{Faker::Lorem.word}-#{n}" }
    sequence(:name_url)                     { |n| "#{Faker::Internet.slug}-#{n}" }
    sorting_order                           { 1 }
    active                                  { false }
    cme_count                               { 1 }
    video_count                             { 1 }
    quiz_count                              { 1 }
    description                             { Faker::Lorem.sentence }
    default_number_of_possible_exam_answers { 4 }
    quiz_pass_rate                          { 10 }
    survey_url                              { 'SurveyURL' }
    category_label                          { 'Category' }
    icon_label                              { 'Icon' }
    group
    exam_body
    level

    factory :active_course do
      active  { true }
      preview { false }
    end

    factory :inactive_course do
      active { false }
    end

    factory :preview_course do
      active  { true }
      preview { true }
    end
  end
end
