# == Schema Information
#
# Table name: products
#
#  id                :integer          not null, primary key
#  name              :string
#  subject_course_id :integer
#  mock_exam_id      :integer
#  stripe_guid       :string
#  live_mode         :boolean          default(FALSE)
#  created_at        :datetime         not null
#  updated_at        :datetime         not null
#  active            :boolean          default(FALSE)
#  currency_id       :integer
#  price             :decimal(, )
#  stripe_sku_guid   :string
#

FactoryBot.define do
  factory :product do
    sequence(:name)                  { |n| "Product-00#{n}" }
    mock_exam_id 1
    active true
    sequence(:stripe_guid)           { |n| "stripe-guid-#{n}" }
    live_mode false
    price '999'
    currency_id 1
    sequence(:stripe_sku_guid)           { |n| "stripe-sku-guid-#{n}" }
  end

end
