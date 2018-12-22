# == Schema Information
#
# Table name: course_section_user_logs
#
#  id                              :integer          not null, primary key
#  user_id                         :integer
#  course_section_id               :integer
#  subject_course_user_log_id      :integer
#  latest_course_module_element_id :integer
#  percentage_complete             :float
#  count_of_cmes_completed         :integer
#  count_of_quizzes_taken          :integer
#  count_of_videos_taken           :integer
#  created_at                      :datetime         not null
#  updated_at                      :datetime         not null
#  subject_course_id               :integer
#

FactoryBot.define do
  factory :course_section_user_log do
    user_id 1
    latest_course_module_element_id 1
    course_section_id 1
    percentage_complete 1.5
    count_of_cmes_completed 1
    subject_course_user_log_id 1
    count_of_quizzes_taken 1
    count_of_videos_taken 1
  end
end
