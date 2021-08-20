# == Schema Information
#
# Table name: enrollments
#
#  id                  :integer          not null, primary key
#  user_id             :integer
#  course_id           :integer
#  course_log_id       :integer
#  created_at          :datetime         not null
#  updated_at          :datetime         not null
#  active              :boolean          default("false")
#  exam_body_id        :integer
#  exam_date           :date
#  expired             :boolean          default("false")
#  paused              :boolean          default("false")
#  notifications       :boolean          default("true")
#  exam_sitting_id     :integer
#  computer_based_exam :boolean          default("false")
#  percentage_complete :integer          default("0")
#

FactoryBot.define do
  factory :enrollment do
    user_id { 1 }
    course_id { 1 }
    course_log_id { 11 }
    exam_date { (Date.today + 1.years).strftime("%Y-%m-%d") }
    exam_body_id { 1 }
    expired { false }
    paused { false }
    exam_sitting_id { 1 }
    notifications { true }
    computer_based_exam { false }
    percentage_complete { 0 }
  end

end
