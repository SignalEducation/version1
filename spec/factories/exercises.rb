# == Schema Information
#
# Table name: exercises
#
#  id         :bigint(8)        not null, primary key
#  product_id :bigint(8)
#  state      :string
#  created_at :datetime         not null
#  updated_at :datetime         not null
#

FactoryBot.define do
  factory :exercise do
    product { nil }
    state { "MyString" }
  end
end
