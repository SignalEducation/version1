# == Schema Information
#
# Table name: corporate_customers
#
#  id                   :integer          not null, primary key
#  created_at           :datetime
#  updated_at           :datetime
#  organisation_name    :string
#  address              :text
#  owner_id             :integer
#  country_id           :integer
#  payments_by_card     :boolean          default(FALSE), not null
#  is_university        :boolean          default(FALSE), not null
#  stripe_customer_guid :string
#  can_restrict_content :boolean          default(FALSE), not null
#  logo_file_name       :string
#  logo_content_type    :string
#  logo_file_size       :integer
#  logo_updated_at      :datetime
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
