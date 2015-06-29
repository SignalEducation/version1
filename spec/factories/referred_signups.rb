# == Schema Information
#
# Table name: referred_signups
#
#  id               :integer          not null, primary key
#  referral_code_id :integer
#  user_id          :integer
#  referrer_url     :string(2048)
#  subscription_id  :integer
#  maturing_on      :datetime
#  payed_at         :datetime
#  created_at       :datetime         not null
#  updated_at       :datetime         not null
#

FactoryGirl.define do
  factory :referred_signup do
    referral_code_id 1
    user_id 1
    referrer_url "http://example.com/referral"
    maturing_on nil
    payed_at "2015-05-25 14:11:12"
  end
end
