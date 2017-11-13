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
#

FactoryGirl.define do
  factory :exam_sitting do
    sequence(:name)           { |n| "Exam Sitting #{n}" }
    subject_course_id 1
    exam_body_id 1
    date "2016-10-26"
  end

end
