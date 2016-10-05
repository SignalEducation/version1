# == Schema Information
#
# Table name: subject_course_categories
#
#  id           :integer          not null, primary key
#  name         :string
#  payment_type :string
#  active       :boolean          default(FALSE)
#  subdomain    :string
#  created_at   :datetime         not null
#  updated_at   :datetime         not null
#

FactoryGirl.define do
  factory :subject_course_category do
    name 'Course Category'
    payment_type 'Subscription'
    active false
    subdomain "MyString"


    factory :product_course_category do
      name 'Product Course Category'
      payment_type 'Product'
      active true
    end

    factory :subscription_course_category do
      name 'Subscription Course Category'
      payment_type 'Subscription'
      active true
    end

    factory :corporate_course_category do
      name 'Corporate Course Category'
      payment_type 'Corporate'
      active true
    end

  end

end
