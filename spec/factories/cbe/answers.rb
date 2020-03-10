# == Schema Information
#
# Table name: cbe_answers
#
#  id              :bigint           not null, primary key
#  kind            :integer
#  content         :json
#  created_at      :datetime         not null
#  updated_at      :datetime         not null
#  cbe_question_id :bigint
#
FactoryBot.define do
  factory :cbe_answer, class: Cbe::Answer do
    kind    { Cbe::Answer.kinds.keys.sample }
    content { { text: Faker::Lorem.sentence, correct: [true, false].sample } }

    trait :with_question do
      association :question, :with_section, factory: :cbe_question
    end
  end
end
