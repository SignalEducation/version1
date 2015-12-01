# == Schema Information
#
# Table name: completion_certificates
#
#  id                         :integer          not null, primary key
#  user_id                    :integer
#  subject_course_user_log_id :integer
#  guid                       :string
#  created_at                 :datetime         not null
#  updated_at                 :datetime         not null
#

FactoryGirl.define do
  factory :completion_certificate do
    user_id 1
subject_course_userLog_id 1
guid "MyString"
  end

end
