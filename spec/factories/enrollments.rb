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
#

FactoryGirl.define do
  factory :enrollment do
    user_id 1
subject_course_id 1
subject_course_user_log_id ""
  end

end
