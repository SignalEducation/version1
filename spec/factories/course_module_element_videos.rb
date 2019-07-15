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
    duration { 10 }
    course_module_element

    trait :vimeo do
      sequence(:vimeo_guid) { |n| "vimeo-#{n}" }
    end

    trait :dacast do
      vimeo_guid { 'not empty' }
      sequence(:dacast_id) { |n| "dacast-#{n}" }
    end
  end
end
