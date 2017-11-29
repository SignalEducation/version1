# == Schema Information
#
# Table name: coupons
#
#  id                 :integer          not null, primary key
#  name               :string
#  code               :string
#  currency_id        :integer
#  livemode           :boolean          default(FALSE)
#  active             :boolean          default(FALSE)
#  amount_off         :integer
#  duration           :string
#  duration_in_months :integer
#  max_redemptions    :integer
#  percent_off        :integer
#  redeem_by          :datetime
#  times_redeemed     :integer
#  created_at         :datetime         not null
#  updated_at         :datetime         not null
#

FactoryGirl.define do
  factory :coupon do
    stripe_id "MyString"
currency_id 1
livemode false
active false
amount_off 1
duration "MyString"
duration_in_months 1
max_redemptions 1
percent_off 1
redeem_by "2017-11-29 16:14:46"
times_redeemed 1
valid false
  end

end
