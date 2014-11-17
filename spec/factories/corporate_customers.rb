# == Schema Information
#
# Table name: corporate_customers
#
#  id                   :integer          not null, primary key
#  organisation_name    :string(255)
#  address              :text
#  country_id           :integer
#  payments_by_card     :boolean          default(FALSE), not null
#  is_university        :boolean          default(FALSE), not null
#  owner_id             :integer
#  stripe_customer_guid :string(255)
#  can_restrict_content :boolean          default(FALSE), not null
#  created_at           :datetime
#  updated_at           :datetime
#

FactoryGirl.define do
  factory :corporate_customer do
    sequence(:organisation_name)  {|n| "Customer #{n}"}
    address                       'MyText'
    country_id                    1 # todo { Country.first.try(:id) || 1 }
    payments_by_card              true
    is_university                 false
    owner_id                      { User.first.try(:id) || 1 }
    stripe_customer_guid          'MyString'
    can_restrict_content          false
  end

end
