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
    name "MyString"
    description "MyText"
    subscription false
    product_order false
  end

end
