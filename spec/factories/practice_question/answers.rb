# frozen_string_literal: true

# == Schema Information
#
# Table name: practice_question_answers
#
#  id                            :bigint           not null, primary key
#  content                       :json
#  practice_question_question_id :bigint
#  created_at                    :datetime         not null
#  updated_at                    :datetime         not null
#  course_step_log_id            :bigint
#
FactoryBot.define do
  factory :practice_question_answers, class: ::PracticeQuestion::Answer do
    content { { text: Faker::Lorem.sentence } }

    trait :with_question do
      association :question, factory: :practice_question_questions
    end
  end
end
