# == Schema Information
#
# Table name: course_videos
#
#  id                       :integer          not null, primary key
#  course_step_id :integer
#  created_at               :datetime
#  updated_at               :datetime
#  destroyed_at             :datetime
#  video_id                 :string
#  duration                 :float
#  vimeo_guid               :string
#  dacast_id                :string
#

FactoryBot.define do
  factory :course_video do
    duration { 10 }
    course_step

    trait :vimeo do
      sequence(:vimeo_guid) { |n| "vimeo-#{n}" }
    end

    trait :dacast do
      vimeo_guid { 'not empty' }
      sequence(:dacast_id) { |n| "dacast-#{n}" }
    end

    trait :real_video_ids do
      vimeo_guid { 417525861 }
      dacast_id  { 722491 }
    end
  end
end
