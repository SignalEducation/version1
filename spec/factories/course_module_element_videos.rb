# == Schema Information
#
# Table name: course_module_element_videos
#
#  id                           :integer          not null, primary key
#  course_module_element_id     :integer
#  raw_video_file_id            :integer
#  name                         :string(255)
#  run_time_in_seconds          :integer
#  tutor_id                     :integer
#  description                  :text
#  tags                         :string(255)
#  difficulty_level             :string(255)
#  estimated_study_time_seconds :integer
#  transcript                   :text
#  created_at                   :datetime
#  updated_at                   :datetime
#

FactoryGirl.define do
  factory :course_module_element_video do
    course_module_element_id 1
    raw_video_file_id 1
    name "MyString"
    run_time_in_seconds 1
    tutor_id 1
    description "MyText"
    tags "MyString"
    difficulty_level 'easy'
    estimated_study_time_seconds 1
    transcript "MyText"
  end

end
