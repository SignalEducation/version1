# == Schema Information
#
# Table name: user_exam_sittings
#
#  id                :integer          not null, primary key
#  user_id           :integer
#  exam_sitting_id   :integer
#  subject_course_id :integer
#  date              :date
#  created_at        :datetime         not null
#  updated_at        :datetime         not null
#

FactoryGirl.define do
  factory :user_exam_sitting do
    user_id 1
    exam_sitting_id 1
    subject_course_id 1
    date "2016-10-26"
  end

end
