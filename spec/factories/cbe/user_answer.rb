FactoryBot.define do
  factory :cbe_user_answer, class: Cbe::UserAnswer do
    content         { { text: Faker::Lorem.sentence, correct: Faker::Boolean.boolean } }
    cbe_answer_id   { 1 }

    trait :with_question do
      question { create :cbe_question, :with_section }
    end
  end
end
