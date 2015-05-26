FactoryGirl.define do
  factory :referred_signup do
    referral_code_id 1
    user_id 1
    maturing_on "2015-05-25 14:11:12"
    payed_at "2015-05-25 14:11:12"
  end
end
