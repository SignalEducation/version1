FactoryGirl.define do
  factory :course_module_element_video do
    course_module_element_id 1
    raw_video_file_id 1
    name "MyString"
    run_time_in_seconds 1
    tutor_id 1
    description "MyText"
    tags "MyString"
    difficulty_level "MyString"
    estimated_study_time_seconds 1
    transcript "MyText"
  end

end
