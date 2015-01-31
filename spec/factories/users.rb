# == Schema Information
#
# Table name: users
#
#  id                                       :integer          not null, primary key
#  email                                    :string(255)
#  first_name                               :string(255)
#  last_name                                :string(255)
#  address                                  :text
#  country_id                               :integer
#  crypted_password                         :string(128)      default(""), not null
#  password_salt                            :string(128)      default(""), not null
#  persistence_token                        :string(255)
#  perishable_token                         :string(128)
#  single_access_token                      :string(255)
#  login_count                              :integer          default(0)
#  failed_login_count                       :integer          default(0)
#  last_request_at                          :datetime
#  current_login_at                         :datetime
#  last_login_at                            :datetime
#  current_login_ip                         :string(255)
#  last_login_ip                            :string(255)
#  account_activation_code                  :string(255)
#  account_activated_at                     :datetime
#  active                                   :boolean          default(FALSE), not null
#  user_group_id                            :integer
#  password_reset_requested_at              :datetime
#  password_reset_token                     :string(255)
#  password_reset_at                        :datetime
#  stripe_customer_id                       :string(255)
#  corporate_customer_id                    :integer
#  corporate_customer_user_group_id         :integer
#  operational_email_frequency              :string(255)
#  study_plan_notifications_email_frequency :string(255)
#  falling_behind_email_alert_frequency     :string(255)
#  marketing_email_frequency                :string(255)
#  marketing_email_permission_given_at      :datetime
#  blog_notification_email_frequency        :string(255)
#  forum_notification_email_frequency       :string(255)
#  created_at                               :datetime
#  updated_at                               :datetime
#  locale                                   :string(255)
#  guid                                     :string(255)
#

FactoryGirl.define do
  factory :user do
    sequence(:email)      { |n| "horace.smyth-#{n}@example.com" }
    first_name            'Horace'
    last_name             'Smyth'
    country_id            { Country.first.try(:id) || 1 }
    password              'letSomeone1n'
    password_confirmation 'letSomeone1n'
    operational_email_frequency               'daily'
    study_plan_notifications_email_frequency  'daily'
    falling_behind_email_alert_frequency      'daily'
    marketing_email_frequency                 'daily'
    marketing_email_permission_given_at       Time.parse('2014-10-24 11:30:00')
    blog_notification_email_frequency         'daily'
    forum_notification_email_frequency        'daily'
    active                                    true
    locale                                    'en'

    factory :individual_student_user do
      active                            true
      user_group_id                     1
      stripe_customer_id                'cu_abc123'
      corporate_customer_id             nil
      corporate_customer_user_group_id  nil
      account_activation_code           'abc123'

      factory :inactive_individual_student_user do
        active                          false
        account_activation_code         'abcde12345'
        account_activated_at            nil
      end

      factory :user_with_reset_requested do
        active                          false
        password_reset_token            'A1234567890123456789'
        password_reset_requested_at     { Time.now - 1.day }
      end
   end

    factory :tutor_user do
      active                            true
      user_group_id                     1
      stripe_customer_id                nil
      corporate_customer_id             nil
      corporate_customer_user_group_id  nil
    end

    factory :corporate_student_user do
      active                            true
      user_group_id                     1
      stripe_customer_id                nil
      corporate_customer_id             1
      corporate_customer_user_group_id  1
    end

    factory :corporate_customer_user do
      active                            true
      user_group_id                     1
      stripe_customer_id                nil
      corporate_customer_id             1
      corporate_customer_user_group_id  1
    end

    factory :blogger_user do
      active                            true
      user_group_id                     1
      stripe_customer_id                nil
      corporate_customer_id             nil
      corporate_customer_user_group_id  nil
    end

    factory :forum_manager_user do
      active                            true
      user_group_id                     1
      stripe_customer_id                nil
      corporate_customer_id             nil
      corporate_customer_user_group_id  nil
    end

    factory :content_manager_user do
      active                            true
      user_group_id                     1
      stripe_customer_id                nil
      corporate_customer_id             nil
      corporate_customer_user_group_id  nil
    end

    factory :admin_user do
      active                            true
      user_group_id                     1
      stripe_customer_id                nil
      corporate_customer_id             nil
      corporate_customer_user_group_id  nil
    end

  end

end
