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
#  student_number             :string
#  exam_body_id               :integer
#  exam_date                  :date
#  registered                 :boolean          default(FALSE)
#

FactoryGirl.define do
  factory :enrollment do
    user_id 1
    subject_course_id 1
    student_number 123534
    exam_date "2017-01-17"
    exam_body_id 1
    registered true
  end

end
