# == Schema Information
#
# Table name: corporate_customers
#
#  id                   :integer          not null, primary key
#  created_at           :datetime
#  updated_at           :datetime
#  organisation_name    :string
#  address              :text
#  country_id           :integer
#  payments_by_card     :boolean          default(FALSE), not null
#  stripe_customer_guid :string
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
    payments_by_card              false
    stripe_customer_guid          'MyString'
  end

end
