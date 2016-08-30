# == Schema Information
#
# Table name: user_groups
#
#  id                                   :integer          not null, primary key
#  name                                 :string
#  description                          :text
#  individual_student                   :boolean          default(FALSE), not null
#  corporate_student                    :boolean          default(FALSE), not null
#  tutor                                :boolean          default(FALSE), not null
#  content_manager                      :boolean          default(FALSE), not null
#  blogger                              :boolean          default(FALSE), not null
#  corporate_customer                   :boolean          default(FALSE), not null
#  site_admin                           :boolean          default(FALSE), not null
#  forum_manager                        :boolean          default(FALSE), not null
#  subscription_required_at_sign_up     :boolean          default(FALSE), not null
#  subscription_required_to_see_content :boolean          default(FALSE), not null
#  created_at                           :datetime
#  updated_at                           :datetime
#  product_required_to_see_content      :boolean          default(FALSE)
#  product_student                      :boolean          default(FALSE)
#

FactoryGirl.define do
  factory :user_group do
    sequence(:name)                      { |n| "User Group #{n}" }
    description                          'Lorem ipsum'
    individual_student                   false
    corporate_student                    false
    tutor                                false
    content_manager                      false
    blogger                              false
    corporate_customer                   false
    site_admin                           false
    forum_manager                        false
    subscription_required_at_sign_up     false
    subscription_required_to_see_content false

    factory :blogger_user_group do
      name 'Blogger Group'
      blogger true
    end

    factory :corporate_student_user_group do
      name 'Corporate Student Group'
      individual_student false
      corporate_student true
      subscription_required_at_sign_up false
      subscription_required_to_see_content false
    end

    factory :corporate_customer_user_group do
      name 'Corporate Customer Group'
      corporate_customer true
      tutor   true
      subscription_required_at_sign_up false
      subscription_required_to_see_content false
    end

    factory :content_manager_user_group do
      name 'Content Manager Group'
      content_manager true
    end

    factory :forum_manager_user_group do
      name 'Forum Manager Group'
      forum_manager true
    end

    factory :individual_student_user_group do
      name 'Individual Student Group'
      individual_student true
      subscription_required_at_sign_up true
      subscription_required_to_see_content true
    end

    factory :site_admin_user_group do
      name 'Site Admin Group'
      site_admin true
    end

    factory :tutor_user_group do
      name 'Tutor Group'
      tutor true
    end

  end
end
