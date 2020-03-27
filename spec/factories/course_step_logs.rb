FactoryBot.define do
  factory :course_step_log do
    course_step_id { 1 }
    user_id { 1 }
    session_guid { "MyString" }
    element_completed { false }
    time_taken_in_seconds { 1 }
    quiz_score_actual { 1 }
    quiz_score_potential { 1 }
    is_video { false }
    is_quiz { false }
    course_lesson_id { 1 }
    latest_attempt { false }
    count_of_questions_taken { 1 }
    count_of_questions_correct { 1 }
    course_log_id { 1 }


    factory :quiz_cmeul do
      is_quiz { true }
    end

    factory :video_cmeul do
      is_video { true }
    end

    factory :cr_cmeul do
      is_constructed_response { true }
    end

  end

end
