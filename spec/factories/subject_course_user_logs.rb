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
#  count_of_questions_correct      :integer
#  count_of_questions_taken        :integer
#  count_of_videos_taken           :integer
#  count_of_quizzes_taken          :integer
#  completed_at                    :datetime
#

FactoryGirl.define do
  factory :subject_course_user_log do
    user_id 1
    session_guid "MyString"
    subject_course_id 1
    percentage_complete 1
    latest_course_module_element_id 1
    completed false
  end

end
