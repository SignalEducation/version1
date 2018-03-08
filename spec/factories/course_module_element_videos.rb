# == Schema Information
#
# Table name: course_module_element_videos
#
#  id                       :integer          not null, primary key
#  course_module_element_id :integer
#  created_at               :datetime
#  updated_at               :datetime
#  destroyed_at             :datetime
#  video_id                 :string
#  duration                 :float
#  vimeo_guid               :string
#

FactoryBot.define do
  factory :course_module_element_video do
    course_module_element_id 1
    duration 10
    sequence(:vimeo_guid)             { |n| "vimeo-#{n}" }
  end

end
