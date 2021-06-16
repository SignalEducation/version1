# == Schema Information
#
# Table name: user_groups
#
#  id                           :integer          not null, primary key
#  name                         :string(255)
#  description                  :text
#  tutor                        :boolean          default("false"), not null
#  site_admin                   :boolean          default("false"), not null
#  created_at                   :datetime
#  updated_at                   :datetime
#  system_requirements_access   :boolean          default("false")
#  content_management_access    :boolean          default("false")
#  stripe_management_access     :boolean          default("false")
#  user_management_access       :boolean          default("false")
#  developer_access             :boolean          default("false")
#  user_group_management_access :boolean          default("false")
#  student_user                 :boolean          default("false")
#  trial_or_sub_required        :boolean          default("false")
#  blocked_user                 :boolean          default("false")
#  marketing_resources_access   :boolean          default("false")
#  exercise_corrections_access  :boolean          default("false")
#

FactoryBot.define do
  factory :user_group do
    sequence(:name)              { |n| "User Group #{n}" }
    description                  { 'Lorem ipsum' }
    tutor                        { false }
    system_requirements_access   { false }
    content_management_access    { false }
    stripe_management_access     { false }
    user_management_access       { false }
    developer_access             { false }
    marketing_resources_access   { false }
    user_group_management_access { false }
    student_user                 { false }
    trial_or_sub_required        { false }
    blocked_user                 { false }

    factory :student_user_group do
      name { 'Individual Student Group' }
      student_user                      { true }
      trial_or_sub_required             { true }
    end

    factory :complimentary_user_group do
      name { 'Comp User Group' }
      student_user                      { true }
      trial_or_sub_required             { false }
    end

    factory :tutor_user_group do
      name { 'Tutor Group' }
      tutor                             { true }
      trial_or_sub_required             { false }
    end

    factory :system_requirements_user_group do
      name { 'System Requirements User Group' }
      system_requirements_access { true }
    end

    factory :content_management_user_group do
      name { 'Content Management User Group' }
      content_management_access { true }
    end

    factory :stripe_management_user_group do
      name { 'Stripe Management User Group' }
      stripe_management_access { true }
    end

    factory :user_management_user_group do
      name { 'User Management User Group' }
      user_management_access { true }
    end

    factory :developers_user_group do
      name             { 'Developers User Group' }
      developer_access { true }
    end

    factory :exercise_corrections_user_group do
      name                        { 'Exercise Correction User Group' }
      exercise_corrections_access { true }
    end

    factory :marketing_manager_user_group do
      name { 'Marketing Manager User Group' }
      marketing_resources_access { true }
    end

    factory :user_group_manager_user_group do
      name { 'User Group Manager' }
      user_group_management_access { true }
    end

    factory :admin_user_group do
      name { 'Site Admin Group' }
      system_requirements_access   { true }
      content_management_access    { true }
      stripe_management_access     { true }
      user_management_access       { true }
      developer_access             { false }
      user_group_management_access { true }
      site_admin                   { true }
    end

    factory :blocked_user_group do
      name { 'Blocked Users User Group' }
      blocked_user { true }
    end
  end
end
