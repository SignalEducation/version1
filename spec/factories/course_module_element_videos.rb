# == Schema Information
#
# Table name: course_module_element_videos
#
#  id                           :integer          not null, primary key
#  course_module_element_id     :integer
#  tags                         :string
#  difficulty_level             :string
#  estimated_study_time_seconds :integer
#  transcript                   :text
#  created_at                   :datetime
#  updated_at                   :datetime
#  destroyed_at                 :datetime
#  video_id                     :string
#  duration                     :float
#  thumbnail                    :text
#

FactoryGirl.define do
  factory :course_module_element_video do
    course_module_element_id 1
    tags "MyString"
    difficulty_level 'easy'
    estimated_study_time_seconds 1
    transcript "MyText"
    video_id 'abc123'
    duration 1
  end

end
