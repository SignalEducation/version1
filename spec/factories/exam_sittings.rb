# == Schema Information
#
# Table name: exam_sittings
#
#  id                :integer          not null, primary key
#  name              :string
#  subject_course_id :integer
#  date              :date
#  created_at        :datetime         not null
#  updated_at        :datetime         not null
#  exam_body_id      :integer
#  active            :boolean          default(TRUE)
#  computer_based    :boolean          default(FALSE)
#

FactoryBot.define do
  factory :exam_sitting do
    sequence(:name)           { |n| "Exam Sitting #{n}" }
    exam_body_id 1
    subject_course_id 1
    active true
    date "2019-10-26"


    factory :standard_exam_sitting do
      computer_based false
    end

    factory :computer_based_exam_sitting do
      computer_based true
    end

  end

end
