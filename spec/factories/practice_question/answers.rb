# frozen_string_literal: true

FactoryBot.define do
  factory :practice_question_answers, class: ::PracticeQuestion::Answer do
    content { { text: Faker::Lorem.sentence } }

    trait :with_question do
      association :question, factory: :practice_question_questions
    end
  end
end
