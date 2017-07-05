# == Schema Information
#
# Table name: course_module_element_videos
#
#  id                           :integer          not null, primary key
#  course_module_element_id     :integer
#  estimated_study_time_seconds :integer
#  created_at                   :datetime
#  updated_at                   :datetime
#  destroyed_at                 :datetime
#  video_id                     :string
#  duration                     :float
#  vimeo_guid                   :string
#

FactoryGirl.define do
  factory :course_module_element_video do
    course_module_element_id 1
    estimated_study_time_seconds 1
    duration 1
    sequence(:vimeo_guid)             { |n| "vimeo-#{n}" }
  end

end
