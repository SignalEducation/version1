# == Schema Information
#
# Table name: course_module_element_videos
#
#  id                           :integer          not null, primary key
#  course_module_element_id     :integer
#  raw_video_file_id            :integer
#  tags                         :string
#  difficulty_level             :string
#  estimated_study_time_seconds :integer
#  transcript                   :text
#  created_at                   :datetime
#  updated_at                   :datetime
#  destroyed_at                 :datetime
#

FactoryGirl.define do
  factory :course_module_element_video do
    course_module_element_id 1
    raw_video_file_id 1
    tags "MyString"
    difficulty_level 'easy'
    estimated_study_time_seconds 1
    transcript "MyText"
  end

end
