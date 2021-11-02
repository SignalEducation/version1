# frozen_string_literal: true

# == Schema Information
#
# Table name: practice_question_responses
#
#  id                   :bigint           not null, primary key
#  practice_question_id :integer
#  sorting_order        :integer
#  kind                 :integer
#  content              :json
#  course_step_log_id   :bigint
#  created_at           :datetime         not null
#  updated_at           :datetime         not null
#
FactoryBot.define do
  factory :practice_question_responses, class: ::PracticeQuestion::Response do
    content                   { { text: Faker::Lorem.sentence } }
    kind                      { ::PracticeQuestion::Response.kinds.keys.sample }
    sequence(:sorting_order)  { |n| n * 10 }

    association :practice_question_id, factory: :practice_question
    association :course_step_log_id, factory: :course_step_log, strategy: :null

    trait :skip_validate do
      to_create {|instance| instance.save(validate: false)}
    end
  end
end
