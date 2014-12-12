# == Schema Information
#
# Table name: course_module_elements
#
#  id                        :integer          not null, primary key
#  name                      :string(255)
#  name_url                  :string(255)
#  description               :text
#  estimated_time_in_seconds :integer
#  course_module_id          :integer
#  sorting_order             :integer
#  forum_topic_id            :integer
#  tutor_id                  :integer
#  related_quiz_id           :integer
#  related_video_id          :integer
#  created_at                :datetime
#  updated_at                :datetime
#  is_video                  :boolean          default(FALSE), not null
#  is_quiz                   :boolean          default(FALSE), not null
#

FactoryGirl.define do
  factory :course_module_element do
    sequence(:name)             { |n| "Course Module Element #{n}" }
    sequence(:name_url)         { |n| "course-module-element-#{n}" }
    description                 'Lorem ipsum'
    estimated_time_in_seconds   1
    course_module_id            1
    course_video_id             1
    course_quiz_id              1
    sorting_order               1
    forum_topic_id              1
    tutor_id                    1
    related_quiz_id             1
    related_video_id            1
  end

end
