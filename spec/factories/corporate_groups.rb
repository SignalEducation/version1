# == Schema Information
#
# Table name: corporate_groups
#
#  id                    :integer          not null, primary key
#  corporate_customer_id :integer
#  name                  :string
#  created_at            :datetime         not null
#  updated_at            :datetime         not null
#

FactoryGirl.define do
  factory :corporate_group do
    corporate_customer_id 1
    sequence(:name) { |n| "Corporate Group #{n}" }
  end
end
