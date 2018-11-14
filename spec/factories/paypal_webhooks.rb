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
#  valid        :boolean          default(TRUE)
#

FactoryBot.define do
  factory :paypal_webhook do
    guid "MyString"
    payload "MyText"
    processed_at "2018-11-14 11:43:47"
  end
end
