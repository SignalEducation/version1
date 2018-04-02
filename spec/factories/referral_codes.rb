# == Schema Information
#
# Table name: referral_codes
#
#  id         :integer          not null, primary key
#  user_id    :integer
#  code       :string(7)
#  created_at :datetime         not null
#  updated_at :datetime         not null
#

FactoryBot.define do
  factory :referral_code do
    sequence(:code) { |n| "rc#{n}" }
    user_id { User.first.try(:id) || 1 }
  end
end
