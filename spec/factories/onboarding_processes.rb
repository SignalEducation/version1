# == Schema Information
#
# Table name: onboarding_processes
#
#  id                   :bigint           not null, primary key
#  user_id              :integer
#  course_log_id        :integer
#  active               :boolean          default("true"), not null
#  created_at           :datetime         not null
#  updated_at           :datetime         not null
#  course_lesson_log_id :integer
#
FactoryBot.define do
  factory :onboarding_process do
    active { true }
    user
    course_lesson_log
  end
end
