# == Schema Information
#
# Table name: institution_users
#
#  id                          :integer          not null, primary key
#  institution_id              :integer
#  user_id                     :integer
#  student_registration_number :string(255)
#  student                     :boolean          default(FALSE), not null
#  qualified                   :boolean          default(FALSE), not null
#  created_at                  :datetime
#  updated_at                  :datetime
#  exam_number                 :string(255)
#  membership_number           :string(255)
#

FactoryGirl.define do
  factory :institution_user do
    institution_id  { Institution.first.try(:id) || 1 }
    user_id         { User.first.try(:id) || 1 }
    student_registration_number 'ABC-123123'

    factory :student_institution_user do
      student       true
      qualified     false
    end

    factory :member_institution_user do
      student       false
      qualified     true
    end
  end

end
