# == Schema Information
#
# Table name: course_modules
#
#  id                         :integer          not null, primary key
#  name                       :string(255)
#  name_url                   :string(255)
#  description                :text
#  sorting_order              :integer
#  estimated_time_in_seconds  :integer
#  active                     :boolean          default("false"), not null
#  created_at                 :datetime
#  updated_at                 :datetime
#  cme_count                  :integer          default("0")
#  seo_description            :string(255)
#  seo_no_index               :boolean          default("false")
#  destroyed_at               :datetime
#  number_of_questions        :integer          default("0")
#  subject_course_id          :integer
#  video_duration             :float            default("0.0")
#  video_count                :integer          default("0")
#  quiz_count                 :integer          default("0")
#  highlight_colour           :string
#  tuition                    :boolean          default("false")
#  test                       :boolean          default("false")
#  revision                   :boolean          default("false")
#  course_section_id          :integer
#  constructed_response_count :integer          default("0")
#  temporary_label            :string
#

FactoryBot.define do
  factory :course_module do
    association               :subject_course
    association               :course_section
    sequence(:name)           { |n| "Course Module #{n}" }
    sequence(:name_url)       { |n| "course-module-#{n}" }
    description               { 'Lorem ipsum' }
    sequence(:sorting_order)  { |n| n * 100 }
    estimated_time_in_seconds { 0 }
    seo_description           { 'Lorem Ipsum' }
    seo_no_index              { false }

    factory :active_course_module do
      active { true }
    end

    factory :inactive_course_module do
      active { false }
    end

    factory :course_module_with_video do
      association :course_module_element_with_video
    end
  end

end
