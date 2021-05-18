FactoryBot.define do
  factory :cbe_user_question, class: Cbe::UserQuestion do
    score            { Faker::Number.between(from: 1.0, to: 10.0) }
    correct          { Faker::Boolean.boolean }
    educator_comment { Faker::Lorem.sentence }

    user_log         { build(:cbe_user_log) }
    cbe_question     { build(:cbe_question) }
    answers          { build_list(:cbe_user_answer, 5) }
  end
end
