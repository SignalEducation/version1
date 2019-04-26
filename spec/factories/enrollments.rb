# == Schema Information
#
# Table name: enrollments
#
#  id                         :integer          not null, primary key
#  user_id                    :integer
#  subject_course_id          :integer
#  subject_course_user_log_id :integer
#  created_at                 :datetime         not null
#  updated_at                 :datetime         not null
#  active                     :boolean          default(FALSE)
#  exam_body_id               :integer
#  exam_date                  :date
#  expired                    :boolean          default(FALSE)
#  paused                     :boolean          default(FALSE)
#  notifications              :boolean          default(TRUE)
#  exam_sitting_id            :integer
#  computer_based_exam        :boolean          default(FALSE)
#  percentage_complete        :integer          default(0)
#

FactoryBot.define do
  factory :enrollment do
    user_id { 1 }
    subject_course_id { 1 }
    subject_course_user_log_id { 11 }
    exam_date { '2017-01-17' }
    exam_body_id { 1 }
    expired { false }
    paused { false }
    exam_sitting_id { 1 }
    notifications { true }
    computer_based_exam { false }
    percentage_complete { 0 }
  end

end
