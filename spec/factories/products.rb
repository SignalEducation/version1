# == Schema Information
#
# Table name: products
#
#  id                    :integer          not null, primary key
#  name                  :string
#  course_id             :integer
#  mock_exam_id          :integer
#  stripe_guid           :string
#  live_mode             :boolean          default("false")
#  created_at            :datetime         not null
#  updated_at            :datetime         not null
#  active                :boolean          default("false")
#  currency_id           :integer
#  price                 :decimal(, )
#  stripe_sku_guid       :string
#  sorting_order         :integer
#  product_type          :integer          default("0")
#  correction_pack_count :integer
#  cbe_id                :bigint
#  group_id              :integer
#  payment_heading       :string
#  payment_subheading    :string
#  payment_description   :text
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
    group

    factory :mock_product do
      product_type { 'mock_exam' }
    end

    factory :correction_product do
      product_type { 'correction_pack' }
      correction_pack_count { 1 }
    end
  end

  trait :for_mock do
    product_type { 'mock_exam' }
  end

  trait :for_corrections do
    product_type { 'correction_pack' }
    correction_pack_count { 1 }
  end

  trait :inactive do
    active { false }
  end

  trait :with_order do
    orders { build_list :order, 2 }
  end
end
