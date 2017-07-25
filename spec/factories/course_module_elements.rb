# == Schema Information
#
# Table name: course_module_elements
#
#  id                        :integer          not null, primary key
#  name                      :string
#  name_url                  :string
#  description               :text
#  estimated_time_in_seconds :integer
#  course_module_id          :integer
#  sorting_order             :integer
#  created_at                :datetime
#  updated_at                :datetime
#  is_video                  :boolean          default(FALSE), not null
#  is_quiz                   :boolean          default(FALSE), not null
#  active                    :boolean          default(TRUE), not null
#  seo_description           :string
#  seo_no_index              :boolean          default(FALSE)
#  destroyed_at              :datetime
#  number_of_questions       :integer          default(0)
#  duration                  :float            default(0.0)
#

FactoryGirl.define do
  factory :course_module_element do
    sequence(:name)             { |n| "Course Module Element #{n}" }
    sequence(:name_url)         { |n| "course-module-element-#{n}" }
    description                 'Lorem ipsum'
    estimated_time_in_seconds   1
    course_module_id            1
    sorting_order               1
    active                      true
    seo_description             'Lorem Ipsum'
    seo_no_index                false

    factory :cme_video do
      is_video                    true
      is_quiz                     false
    end

    factory :cme_quiz do
      is_quiz                     true
      is_video                    false
    end

  end

end
