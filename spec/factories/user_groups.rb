# == Schema Information
#
# Table name: user_groups
#
#  id                 :integer          not null, primary key
#  name               :string
#  description        :text
#  individual_student :boolean          default(FALSE), not null
#  tutor              :boolean          default(FALSE), not null
#  content_manager    :boolean          default(FALSE), not null
#  blogger            :boolean          default(FALSE), not null
#  site_admin         :boolean          default(FALSE), not null
#  created_at         :datetime
#  updated_at         :datetime
#  complimentary      :boolean          default(FALSE)
#  customer_support   :boolean          default(FALSE)
#  marketing_support  :boolean          default(FALSE)
#

FactoryGirl.define do
  factory :user_group do
    sequence(:name)                      { |n| "User Group #{n}" }
    description                          'Lorem ipsum'
    individual_student                   false
    tutor                                false
    content_manager                      false
    blogger                              false
    site_admin                           false
    complimentary                        false
    customer_support                     false
    marketing_support                    false

    factory :blogger_user_group do
      name 'Blogger Group'
      blogger true
    end

    factory :content_manager_user_group do
      name 'Content Manager Group'
      content_manager true
    end

    factory :individual_student_user_group do
      name 'Individual Student Group'
      individual_student true
      complimentary false
    end

    factory :site_admin_user_group do
      name 'Site Admin Group'
      site_admin true
    end

    factory :tutor_user_group do
      name 'Tutor Group'
      tutor true
    end

    factory :complimentary_user_group do
      name 'Comp User Group'
      complimentary true
    end

    factory :marketing_manager_user_group do
      name 'Marketing Managers User Group'
      complimentary true
      marketing_support true
    end

    factory :customer_support_user_group do
      name 'Customer Support User Group'
      complimentary true
      customer_support true
    end

  end
end
