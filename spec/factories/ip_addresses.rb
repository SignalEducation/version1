# == Schema Information
#
# Table name: ip_addresses
#
#  id           :integer          not null, primary key
#  ip_address   :string(255)
#  latitude     :float
#  longitude    :float
#  country_id   :integer
#  alert_level  :integer
#  created_at   :datetime
#  updated_at   :datetime
#  rechecked_on :datetime
#

FactoryBot.define do
  factory :ip_address do
    ip_address { Faker::Internet.public_ip_v4_address }
    latitude { 1.5 }
    longitude { 1.5 }
    country
    alert_level { 1 }
  end
end
