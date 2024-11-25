# == Schema Information
#
# Table name: invoice_line_items
#
#  id                   :integer          not null, primary key
#  invoice_id           :integer
#  amount               :decimal(, )
#  currency_id          :integer
#  prorated             :boolean
#  period_start_at      :datetime
#  period_end_at        :datetime
#  subscription_id      :integer
#  subscription_plan_id :integer
#  original_stripe_data :text
#  created_at           :datetime
#  updated_at           :datetime
#

FactoryBot.define do
  factory :invoice_line_item do
    invoice
    amount { "9.99" }
    currency
    prorated { false }
    period_start_at { "2015-02-23 15:37:14" }
    period_end_at { "2015-02-23 15:37:14" }
    subscription
    subscription_plan
  end
end
