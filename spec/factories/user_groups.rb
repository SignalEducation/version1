# == Schema Information
#
# Table name: user_groups
#
#  id                           :integer          not null, primary key
#  name                         :string
#  description                  :text
#  individual_student           :boolean          default(FALSE), not null
#  tutor                        :boolean          default(FALSE), not null
#  content_manager              :boolean          default(FALSE), not null
#  blogger                      :boolean          default(FALSE), not null
#  site_admin                   :boolean          default(FALSE), not null
#  created_at                   :datetime
#  updated_at                   :datetime
#  complimentary                :boolean          default(FALSE)
#  customer_support             :boolean          default(FALSE)
#  marketing_support            :boolean          default(FALSE)
#  system_requirements_access   :boolean          default(FALSE)
#  content_management_access    :boolean          default(FALSE)
#  stripe_management_access     :boolean          default(FALSE)
#  user_management_access       :boolean          default(FALSE)
#  developer_access             :boolean          default(FALSE)
#  home_pages_access            :boolean          default(FALSE)
#  user_group_management_access :boolean          default(FALSE)
#  student_user                 :boolean          default(FALSE)
#  trial_or_sub_required        :boolean          default(FALSE)
#  blocked_user                 :boolean          default(FALSE)
#

FactoryGirl.define do
  factory :user_group do
    sequence(:name)                      { |n| "User Group #{n}" }
    description                          'Lorem ipsum'
    tutor                                 false
    system_requirements_access            false
    content_management_access             false
    stripe_management_access              false
    user_management_access                false
    developer_access                      false
    home_pages_access                     false
    user_group_management_access          false
    student_user                          false
    trial_or_sub_required                 false
    blocked_user                          false

    factory :admin_user_group do
      name 'Site Admin Group'
      system_requirements_access            true
      content_management_access             true
      stripe_management_access              true
      user_management_access                true
      developer_access                      true
      user_group_management_access          true
    end

    factory :student_user_group do
      name 'Individual Student Group'
      student_user                      true
      trial_or_sub_required             true
    end

    factory :tutor_user_group do
      name 'Tutor Group'
      tutor                             true
      trial_or_sub_required             false
    end

    factory :content_manager_user_group do
      name 'Content Manager Group'
      content_management_access             true
    end

    factory :complimentary_user_group do
      name 'Comp User Group'
      student_user                      true
      trial_or_sub_required             false
    end

    factory :customer_support_user_group do
      name 'Customer Support User Group'
      user_management_access                true
    end

    factory :marketing_manager_user_group do
      name 'Marketing Managers User Group'
      home_pages_access                true
    end

  end
end
