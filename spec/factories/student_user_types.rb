# == Schema Information
#
# Table name: student_user_types
#
#  id            :integer          not null, primary key
#  name          :string
#  description   :text
#  subscription  :boolean          default(FALSE)
#  product_order :boolean          default(FALSE)
#  created_at    :datetime         not null
#  updated_at    :datetime         not null
#  free_trial    :boolean          default(FALSE)
#

FactoryGirl.define do
  factory :student_user_type do
    sequence(:name)                      { |n| "Studnet Type #{n}" }
    description 'Drectiption of the user type'
    subscription false
    product_order false
    free_trial false


    factory :free_trial_user_type do
      name 'Free Trial Students'
      subscription false
      product_order false
      free_trial true
    end

    factory :subscription_user_type do
      name 'Valid Subscription Students'
      subscription true
      product_order false
      free_trial false
    end

    factory :product_user_type do
      name 'Valid Product Students'
      subscription false
      product_order true
      free_trial false
    end

    factory :sub_and_product_user_type do
      name 'Valid Subscription and Product Students'
      subscription true
      product_order true
      free_trial false
    end

    factory :trial_and_product_user_type do
      name 'Free Trial and Product Students'
      subscription false
      product_order true
      free_trial true
    end

    factory :no_access_user_type do
      name 'No sub or product Students'
      subscription false
      product_order false
      free_trial false
    end

  end
end
