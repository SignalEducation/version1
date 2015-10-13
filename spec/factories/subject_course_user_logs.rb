# == Schema Information
#
# Table name: subject_course_user_logs
#
#  id                              :integer          not null, primary key
#  user_id                         :integer
#  session_guid                    :string
#  subject_course_id               :integer
#  percentage_complete             :integer          default(0)
#  count_of_cmes_completed         :integer          default(0)
#  latest_course_module_element_id :integer
#  completed                       :boolean          default(FALSE)
#  created_at                      :datetime         not null
#  updated_at                      :datetime         not null
#

FactoryGirl.define do
  factory :subject_course_user_log do
    user_id 1
    session_guid "MyString"
    subject_course_id 1
    percentage_complete 1
    count_of_course_module_complete 1
    latest_course_module_element_id 1
    completed false
  end

end
