# == Schema Information
#
# Table name: marketing_tokens
#
#  id                    :integer          not null, primary key
#  code                  :string(255)
#  marketing_category_id :integer
#  is_hard               :boolean          default(FALSE), not null
#  is_direct             :boolean          default(FALSE), not null
#  is_seo                :boolean          default(FALSE), not null
#  created_at            :datetime
#  updated_at            :datetime
#

FactoryGirl.define do
  factory :marketing_token do
    sequence(:code) { |n| "MT_#{n}" }
    marketing_category_id 1
    is_hard false
    is_direct false
    is_seo false
  end

end
