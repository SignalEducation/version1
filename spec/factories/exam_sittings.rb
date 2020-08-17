# == Schema Information
#
# Table name: exam_sittings
#
#  id             :integer          not null, primary key
#  name           :string
#  course_id      :integer
#  date           :date
#  created_at     :datetime         not null
#  updated_at     :datetime         not null
#  exam_body_id   :integer
#  active         :boolean          default("true")
#  computer_based :boolean          default("false")
#

FactoryBot.define do
  factory :exam_sitting do
    sequence(:name)           { |n| "Exam Sitting #{n}" }
    association :exam_body
    association :course
    active { true }
    date { "2019-10-26" }


    factory :standard_exam_sitting do
      computer_based { false }
    end

    factory :computer_based_exam_sitting do
      computer_based { true }
    end

  end

end
