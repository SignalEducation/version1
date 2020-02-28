# == Schema Information
#
# Table name: paypal_webhooks
#
#  id           :integer          not null, primary key
#  guid         :string
#  event_type   :string
#  payload      :text
#  processed_at :datetime
#  created_at   :datetime         not null
#  updated_at   :datetime         not null
#  verified     :boolean          default("true")
#

FactoryBot.define do
  factory :paypal_webhook do
    guid { 'test_paypal_guid' }
    payload { { 'resource' => { 'id' => 'test_12345' } } }
    processed_at { "2018-11-14 11:43:47" }
    event_type { 'paypal.event.type' }
  end
end
