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
#  course_section_id         :integer
#

FactoryBot.define do
  factory :course_module do
    association               :subject_course
    sequence(:name)           { |n| "Course Module #{n}" }
    sequence(:name_url)       { |n| "course-module-#{n}" }
    description               'Lorem ipsum'
    sequence(:sorting_order)  { |n| n * 100 }
    estimated_time_in_seconds 0
    seo_description           'Lorem Ipsum'
    seo_no_index              false

    factory :active_course_module do
      active true
    end

    factory :inactive_course_module do
      active false
    end

    factory :course_module_with_video do
      association :course_module_element_with_video
    end
  end

end
