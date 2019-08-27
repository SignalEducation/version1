FactoryBot.define do
  factory :cbe_answer, class: Cbe::Answer do
    kind    { Cbe::Answer.kinds.keys.sample }
    content { Faker::Lorem.sentence }

    trait :with_question do
      association :question, :with_section, factory: :cbe_question
    end
  end
end
