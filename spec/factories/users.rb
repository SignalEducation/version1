# == Schema Information
#
# Table name: users
#
#  id                               :integer          not null, primary key
#  email                            :string
#  first_name                       :string
#  last_name                        :string
#  address                          :text
#  country_id                       :integer
#  crypted_password                 :string(128)      default(""), not null
#  password_salt                    :string(128)      default(""), not null
#  persistence_token                :string
#  perishable_token                 :string(128)
#  single_access_token              :string
#  login_count                      :integer          default(0)
#  failed_login_count               :integer          default(0)
#  last_request_at                  :datetime
#  current_login_at                 :datetime
#  last_login_at                    :datetime
#  current_login_ip                 :string
#  last_login_ip                    :string
#  account_activation_code          :string
#  account_activated_at             :datetime
#  active                           :boolean          default(FALSE), not null
#  user_group_id                    :integer
#  password_reset_requested_at      :datetime
#  password_reset_token             :string
#  password_reset_at                :datetime
#  stripe_customer_id               :string
#  corporate_customer_id            :integer
#  created_at                       :datetime
#  updated_at                       :datetime
#  locale                           :string
#  guid                             :string
#  trial_ended_notification_sent_at :datetime
#  crush_offers_session_id          :string
#  subscription_plan_category_id    :integer
#  employee_guid                    :string
#  password_change_required         :boolean
#  session_key                      :string
#  first_description                :text
#  second_description               :text
#  wistia_url                       :text
#  personal_url                     :text
#  name_url                         :string
#  qualifications                   :text
#  profile_image_file_name          :string
#  profile_image_content_type       :string
#  profile_image_file_size          :integer
#  profile_image_updated_at         :datetime
#  phone_number                     :string
#  topic_interest                   :string
#  email_verification_code          :string
#  email_verified_at                :datetime
#  email_verified                   :boolean          default(FALSE), not null
#  stripe_account_balance           :integer          default(0)
#  trial_limit_in_seconds           :integer          default(0)
#  free_trial                       :boolean          default(FALSE)
#  trial_limit_in_days              :integer          default(0)
#  student_number                   :string
#  terms_and_conditions             :boolean          default(FALSE)
#  student_user_type_id             :integer
#

FactoryGirl.define do
  factory :user do
    sequence(:email)      { |n| "horace.smyth-#{n}@example.com" }
    first_name            'John'
    last_name             'Smith'
    country_id            { Country.first.try(:id) || 1 }
    password              'letSomeone1n'
    password_confirmation 'letSomeone1n'
    active                                    true
    locale                                    'en'

    factory :individual_student_user do
      sequence(:email)                  { |n| "individual.student-#{n}@example.com" }
      active                            true
      user_group_id                     1
      sequence(:stripe_customer_id)     { |n| "cu_abc#{n}" }
      corporate_customer_id             nil
      account_activation_code           'abc123'

      factory :inactive_individual_student_user do
        sequence(:email)                { |n| "inactive-indie-student-#{n}@example.com" }
        active                          false
        account_activation_code         'abcde12345'
        account_activated_at            nil
      end

      factory :active_individual_student_user do
        sequence(:email)                { |n| "active-student-#{n}@example.com" }
        active                          true
        account_activation_code         'abcde12345'
        account_activated_at            Time.now
        email_verified                          false
        email_verification_code         'abcde12345'
        email_verified_at               nil
      end

      factory :unverified_user do
        sequence(:email)                { |n| "inactive-indie-student-#{n}@example.com" }
        active                          false
        account_activation_code         'abcde12345'
        account_activated_at            nil
        email_verified                  false
        email_verification_code         'abc123456'
        email_verified_at               nil
      end

      factory :verified_user do
        sequence(:email)                { |n| "active-student-#{n}@example.com" }
        active                          true
        account_activation_code         'abcde12345'
        account_activated_at            Time.now
        email_verified                  true
        email_verification_code         nil
        email_verified_at               Time.now
      end

      factory :user_with_reset_requested do
        sequence(:email)                { |n| "reset.me-#{n}@example.com" }
        active                          false
        password_reset_token            'A1234567890123456789'
        password_reset_requested_at     { Time.now - 1.day }
      end
    end

    factory :tutor_user do
      sequence(:email)                  { |n| "tutor.user-#{n}@example.com" }
      active                            true
      user_group_id                     1
      stripe_customer_id                nil
      corporate_customer_id             nil
    end

    factory :corporate_student_user do
      sequence(:email)                  { |n| "corporate.student-#{n}@example.com" }
      active                            true
      user_group_id                     UserGroup::CORPORATE_STUDENTS
      stripe_customer_id                nil
      corporate_customer_id             1
    end

    factory :corporate_customer_user do
      sequence(:email)                  { |n| "corporate.customer-#{n}@example.com" }
      active                            true
      user_group_id                     UserGroup::CORPORATE_CUSTOMERS
      stripe_customer_id                nil
      corporate_customer_id             1
    end

    factory :blogger_user do
      sequence(:email)                  { |n| "blogger.user-#{n}@example.com" }
      active                            true
      user_group_id                     1
      stripe_customer_id                nil
      corporate_customer_id             nil
    end

    factory :forum_manager_user do
      sequence(:email)                  { |n| "forum.manager-#{n}@example.com" }
      active                            true
      user_group_id                     1
      stripe_customer_id                nil
      corporate_customer_id             nil
    end

    factory :content_manager_user do
      sequence(:email)                  { |n| "content.manager-#{n}@example.com" }
      active                            true
      user_group_id                     1
      stripe_customer_id                nil
      corporate_customer_id             nil
    end

    factory :admin_user do
      sequence(:email)                  { |n| "admin.user-#{n}@example.com" }
      active                            true
      user_group_id                     1
      stripe_customer_id                nil
      corporate_customer_id             nil
    end

  end

end
