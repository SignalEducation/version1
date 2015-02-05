# == Schema Information
#
# Table name: course_modules
#
#  id                        :integer          not null, primary key
#  institution_id            :integer
#  qualification_id          :integer
#  exam_level_id             :integer
#  exam_section_id           :integer
#  name                      :string(255)
#  name_url                  :string(255)
#  description               :text
#  tutor_id                  :integer
#  sorting_order             :integer
#  estimated_time_in_seconds :integer
#  active                    :boolean          default(FALSE), not null
#  created_at                :datetime
#  updated_at                :datetime
#

FactoryGirl.define do
  factory :course_module do
    institution_id            1
    association               :exam_level
    exam_section_id           1
    sequence(:name)           { |n| "Course Module #{n}" }
    sequence(:name_url)       { |n| "course-module-#{n}" }
    description               'Lorem ipsum'
    tutor_id                  1
    sequence(:sorting_order)  { |n| n * 100 }
    estimated_time_in_seconds 0

    factory :active_course_module do
      active true
    end

    factory :inactive_course_module do
      active false
    end
  end

end
