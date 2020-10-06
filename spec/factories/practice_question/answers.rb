# == Schema Information
#
# Table name: practice_questions_answers
#
#  id                          :bigint           not null, primary key
#  kind                        :integer
#  content                     :json
#  solution                    :json
#  sorting_order               :integer
#  course_practice_question_id :bigint
#  created_at                  :datetime         not null
#  updated_at                  :datetime         not null
#
FactoryBot.define do
  factory :practice_question_answer, class: ::PracticeQuestion::Answer do
    kind     { ::PracticeQuestion::Answer.kinds.keys.sample }
    content  { { text: Faker::Lorem.sentence } }
    solution { { text: Faker::Lorem.sentence } }
    sequence(:sorting_order)

    trait :with_question do
      association :practice_question, factory: :course_practice_question
    end
  end
end
