# == Schema Information
#
# Table name: course_practice_questions
#
#  id             :bigint           not null, primary key
#  name           :string
#  content        :text
#  kind           :integer
#  estimated_time :integer
#  course_step_id :bigint
#  destroyed_at   :datetime
#  created_at     :datetime         not null
#  updated_at     :datetime         not null
#
FactoryBot.define do
  factory :course_practice_question do
    name           { { text: Faker::Lorem.word } }
    content        { { text: Faker::Lorem.sentence } }
    kind           { CoursePracticeQuestion.kinds.keys.sample }
    estimated_time { 30..160 }
    course_step_id { 1 }

    trait :with_questions do
      questions { build_list :practice_question_questions, 3 }
    end
  end
end
