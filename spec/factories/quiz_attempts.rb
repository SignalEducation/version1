# == Schema Information
#
# Table name: quiz_attempts
#
#  id                                :integer          not null, primary key
#  user_id                           :integer
#  quiz_question_id                  :integer
#  quiz_answer_id                    :integer
#  correct                           :boolean          default("false"), not null
#  course_module_element_user_log_id :integer
#  created_at                        :datetime
#  updated_at                        :datetime
#  score                             :integer          default("0")
#  answer_array                      :string(255)
#

FactoryBot.define do
  factory :quiz_attempt do
    user_id { 1 }
    quiz_question_id { 1 }
    quiz_answer_id { 1 }
    correct { false }
    course_module_element_user_log_id { 1 }
  end

end
