# == Schema Information
#
# Table name: onboarding_processes
#
#  id            :bigint           not null, primary key
#  user_id       :integer
#  course_log_id :integer
#  active        :boolean          default("true"), not null
#  created_at    :datetime         not null
#  updated_at    :datetime         not null
#
FactoryBot.define do
  factory :onboarding_process do
    active         { true }

    association :user
    association :course_log
  end
end