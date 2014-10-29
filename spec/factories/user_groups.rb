# == Schema Information
#
# Table name: user_groups
#
#  id                                   :integer          not null, primary key
#  name                                 :string(255)
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
#

FactoryGirl.define do
  factory :user_group do
    sequence(:name) { |n| "User Group #{n}" }
    description 'Lorem ipsum'

    factory :individual_student_user_group do
      individual_student true
      subscription_required_at_sign_up true
      subscription_required_to_see_content true
    end

    factory :corporate_student_user_group do
      individual_student true
      subscription_required_at_sign_up false
      subscription_required_to_see_content false
    end

    factory :tutor_user_group do
      tutor true
    end

    factory :content_manager_user_group do
      content_manager true
    end

    factory :blogger_user_group do
      blogger true
    end

    factory :corporate_customer_user_group do
      corporate_customer true
    end

    factory :site_admin_user_group do
      site_admin true
    end

    factory :forum_manager_user_group do
      forum_manager true
    end

  end
end
