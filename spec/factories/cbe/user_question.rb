FactoryBot.define do
  factory :cbe_user_question, class: Cbe::UserQuestion do
    score            { Faker::Number.decimal(l_digits: 1, r_digits: 2) }
    correct          { Faker::Boolean.boolean }
    educator_comment { Faker::Lorem.sentence }

    user_log         { build(:cbe_user_log) }
    cbe_question     { build(:cbe_question) }
    answers          { build_list(:cbe_user_answer, 5) }
  end
end
