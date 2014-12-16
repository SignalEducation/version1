# == Schema Information
#
# Table name: system_defaults
#
#  id                               :integer          not null, primary key
#  individual_student_user_group_id :integer
#  corporate_student_user_group_id  :integer
#  corporate_customer_user_group_id :integer
#  created_at                       :datetime
#  updated_at                       :datetime
#

FactoryGirl.define do
  factory :system_default do
    individual_student_user_group_id 1
    corporate_student_user_group_id 1
    corporate_customer_user_group_id 1
  end

end
