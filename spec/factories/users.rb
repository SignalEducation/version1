# == Schema Information
#
# Table name: users
#
#  id                              :integer          not null, primary key
#  email                           :string
#  first_name                      :string
#  last_name                       :string
#  address                         :text
#  country_id                      :integer
#  crypted_password                :string(128)      default(""), not null
#  password_salt                   :string(128)      default(""), not null
#  persistence_token               :string
#  perishable_token                :string(128)
#  single_access_token             :string
#  login_count                     :integer          default(0)
#  failed_login_count              :integer          default(0)
#  last_request_at                 :datetime
#  current_login_at                :datetime
#  last_login_at                   :datetime
#  current_login_ip                :string
#  last_login_ip                   :string
#  account_activation_code         :string
#  account_activated_at            :datetime
#  active                          :boolean          default(FALSE), not null
#  user_group_id                   :integer
#  password_reset_requested_at     :datetime
#  password_reset_token            :string
#  password_reset_at               :datetime
#  stripe_customer_id              :string
#  created_at                      :datetime
#  updated_at                      :datetime
#  locale                          :string
#  guid                            :string
#  subscription_plan_category_id   :integer
#  password_change_required        :boolean
#  session_key                     :string
#  name_url                        :string
#  profile_image_file_name         :string
#  profile_image_content_type      :string
#  profile_image_file_size         :bigint(8)
#  profile_image_updated_at        :datetime
#  email_verification_code         :string
#  email_verified_at               :datetime
#  email_verified                  :boolean          default(FALSE), not null
#  stripe_account_balance          :integer          default(0)
#  free_trial                      :boolean          default(FALSE)
#  terms_and_conditions            :boolean          default(FALSE)
#  date_of_birth                   :date
#  description                     :text
#  analytics_guid                  :string
#  student_number                  :string
#  unsubscribed_from_emails        :boolean          default(FALSE)
#  communication_approval          :boolean          default(FALSE)
#  communication_approval_datetime :datetime
#  preferred_exam_body_id          :bigint(8)
#  currency_id                     :bigint(8)
#

FactoryBot.define do
  factory :user do
    sequence(:email)      { |n| "john.smith-#{n}@example.com" }
    first_name            { Faker::Name.first_name }
    last_name             { Faker::Name.last_name }
    association           :country
    password              { '123123123' }
    password_confirmation { '123123123' }
    active                { true }
    terms_and_conditions  { true }
    locale                { 'en' }
    date_of_birth         { '2001-10-03' }
    student_number        { '123456789' }
    association           :user_group
    association           :preferred_exam_body, factory: :exam_body
    association           :currency

    factory :basic_student do
      sequence(:email)                { |n| "trial.student-#{n}@example.com" }
      active                          { true }
      sequence(:stripe_customer_id)   { |n| "cu_abc#{n}" }
      email_verified                  { true }
      email_verification_code         { nil }
      email_verified_at               { Time.now }
    end

    factory :student_user do
      sequence(:email)                { |n| "individual.student-#{n}@example.com" }
      active                          { true }
      free_trial                      { true }
      sequence(:stripe_customer_id)   { |n| "cu_abc#{n}" }
      account_activation_code         { 'abc123' }
      email_verified                  { true }
      email_verification_code         { nil }
      email_verified_at               { Time.now }
      association :user_group, factory: :student_user_group

      factory :inactive_student_user do
        sequence(:email)                { |n| "inactive-indie-student-#{n}@example.com" }
        active                          { false }
        account_activation_code         { 'abcde12345' }
        account_activated_at            { nil }
      end

      factory :active_student_user do
        sequence(:email)                { |n| "active-student-#{n}@example.com" }
        active                          { true }
        account_activation_code         { SecureRandom.hex(10) }
        account_activated_at            { Time.now }
        email_verified                  { true }
        email_verification_code         { nil }
        email_verified_at               { Time.now }
      end

      factory :unverified_user do
        sequence(:email)                { |n| "unverified-student-user-#{n}@example.com" }
        active                          { true }
        account_activation_code         { nil }
        account_activated_at            { nil }
        email_verified                  { false }
        email_verification_code         { SecureRandom.hex(10) }
        email_verified_at               { nil }
      end

      factory :verified_user do
        sequence(:email)                { |n| "active-student-#{n}@example.com" }
        active                          { true }
        account_activation_code         { 'abcde12345' }
        account_activated_at            { Time.now }
        email_verified                  { true }
        email_verification_code         { nil }
        email_verified_at               { Time.now }
      end

      factory :user_with_reset_requested do
        sequence(:email)                { |n| "reset.me-#{n}@example.com" }
        active                          { false }
        password_reset_token            { 'A1234567890123456789' }
        password_reset_requested_at     { Time.now - 1.day }
      end
    end

    factory :comp_user do
      sequence(:email)        { |n| "comp.user-#{n}@example.com" }
      active                  { true }
      email_verified          { true }
      email_verification_code { nil }
      email_verified_at       { Time.now }
      stripe_customer_id      { nil }
      association :user_group, factory: :complimentary_user_group
    end

    factory :unverified_comp_user do
      sequence(:email)                { |n| "unverified-comp-user-#{n}@example.com" }
      active                          { true }
      account_activation_code         { nil }
      account_activated_at            { Time.now }
      email_verified                  { false }
      email_verification_code         { SecureRandom.hex(10) }
      email_verified_at               { nil }
      password_change_required        { true }
    end

    factory :tutor_user do
      sequence(:email)                  { |n| "tutor.user-#{n}@example.com" }
      sequence(:name_url)               { |n| "tutor_#{n}" }
      active                            { true }
      stripe_customer_id                { nil }
    end

    factory :system_requirements_user do
      sequence(:email)                  { |n| "system.requirements.manager-#{n}@example.com" }
      active                            { true }
      stripe_customer_id                { nil }
    end

    factory :content_management_user do
      sequence(:email)                  { |n| "content.management.user-#{n}@example.com" }
      active                            { true }
      stripe_customer_id                { nil }
    end

    factory :stripe_management_user do
      sequence(:email)                  { |n| "stripe.manager-#{n}@example.com" }
      active                            { true }
      stripe_customer_id                { nil }
    end

    factory :user_management_user do
      sequence(:email)                  { |n| "user.manager-#{n}@example.com" }
      active                            { true }
      stripe_customer_id                { nil }
    end

    factory :developers_user do
      sequence(:email)                  { |n| "developer.user-#{n}@example.com" }
      active                            { true }
      stripe_customer_id                { nil }
    end

    factory :exercise_corrections_user do
      sequence(:email)                  { |n| "corrections.user-#{n}@example.com" }
      active                            { true }
      stripe_customer_id                { nil }
      association :user_group, factory: :exercise_corrections_user_group
    end

    factory :marketing_manager_user do
      sequence(:email)                  { |n| "marketing.manager-#{n}@example.com" }
      active                            { true }
      stripe_customer_id                { nil }
    end

    factory :user_group_manager_user do
      sequence(:email)                  { |n| "user.group.manager-#{n}@example.com" }
      active                            { true }
      stripe_customer_id                { nil }
    end

    factory :admin_user do
      sequence(:email)                  { |n| "admin.user-#{n}@example.com" }
      active                            { true }
      stripe_customer_id                { nil }
      association :user_group, factory: :admin_user_group
    end

    factory :blocked_user do
      sequence(:email)                  { |n| "blocked.user-#{n}@example.com" }
      active                            { true }
      stripe_customer_id                { nil }
    end
  end
end
