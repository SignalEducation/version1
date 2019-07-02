# == Schema Information
#
# Table name: products
#
#  id                    :integer          not null, primary key
#  name                  :string
#  mock_exam_id          :integer
#  stripe_guid           :string
#  live_mode             :boolean          default(FALSE)
#  created_at            :datetime         not null
#  updated_at            :datetime         not null
#  active                :boolean          default(FALSE)
#  currency_id           :integer
#  price                 :decimal(, )
#  stripe_sku_guid       :string
#  subject_course_id     :integer
#  sorting_order         :integer
#  product_type          :integer          default("mock_exam")
#  correction_pack_count :integer
#

FactoryBot.define do
  factory :product do
    sequence(:name)            { |n| "Product-00#{n}" }
    active                     { true }
    sequence(:stripe_guid)     { |n| "stripe-guid-#{n}" }
    live_mode                  { false }
    price                      { '999' }
    sequence(:stripe_sku_guid) { |n| "stripe-sku-guid-#{n}" }
    currency
    mock_exam
  end

  trait :inactive do
    active { false }
  end

  trait :with_order do
    orders { build_list :order, 2 }
  end
end
