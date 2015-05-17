# == Schema Information
#
# Table name: ip_addresses
#
#  id          :integer          not null, primary key
#  ip_address  :string
#  latitude    :float
#  longitude   :float
#  country_id  :integer
#  alert_level :integer
#  created_at  :datetime
#  updated_at  :datetime
#

FactoryGirl.define do
  factory :ip_address do
    ip_address "MyString"
latitude 1.5
longitude 1.5
country_id 1
alert_level 1
  end

end
