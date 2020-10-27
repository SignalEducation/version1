# == Schema Information
#
# Table name: invoices
#
#  id                          :integer          not null, primary key
#  user_id                     :integer
#  subscription_transaction_id :integer
#  subscription_id             :integer
#  number_of_users             :integer
#  currency_id                 :integer
#  vat_rate_id                 :integer
#  created_at                  :datetime
#  updated_at                  :datetime
#  issued_at                   :datetime
#  stripe_guid                 :string(255)
#  sub_total                   :decimal(, )      default("0")
#  total                       :decimal(, )      default("0")
#  total_tax                   :decimal(, )      default("0")
#  stripe_customer_guid        :string(255)
#  object_type                 :string(255)      default("invoice")
#  payment_attempted           :boolean          default("false")
#  payment_closed              :boolean          default("false")
#  forgiven                    :boolean          default("false")
#  paid                        :boolean          default("false")
#  livemode                    :boolean          default("false")
#  attempt_count               :integer          default("0")
#  amount_due                  :decimal(, )      default("0")
#  next_payment_attempt_at     :datetime
#  webhooks_delivered_at       :datetime
#  charge_guid                 :string(255)
#  subscription_guid           :string(255)
#  tax_percent                 :decimal(, )
#  tax                         :decimal(, )
#  original_stripe_data        :text
#  paypal_payment_guid         :string
#  order_id                    :bigint
#  requires_3d_secure          :boolean          default("false")
#  sca_verification_guid       :string
#

FactoryBot.define do
  factory :invoice do
    user
    subscription
    number_of_users { 1 }
    currency
    sub_total { 9.99 }
    total { 9.99 }
    total_tax { 9.99 }
    vat_rate
  end
end
