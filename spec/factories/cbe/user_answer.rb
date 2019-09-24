FactoryBot.define do
  factory :cbe_user_answer, class: Cbe::UserAnswer do
    content         { { text: Faker::Lorem.sentence, correct: Faker::Boolean.boolean } }
    cbe_question_id { 1 }
    cbe_answer_id   { 1 }
  end
end
