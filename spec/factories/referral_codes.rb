FactoryGirl.define do
  factory :referral_code do
    user_id { User.first.try(:id) || 1 }
  end
end
