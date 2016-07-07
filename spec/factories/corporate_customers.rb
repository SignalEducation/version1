# == Schema Information
#
# Table name: corporate_customers
#
#  id                   :integer          not null, primary key
#  organisation_name    :string
#  address              :text
#  country_id           :integer
#  payments_by_card     :boolean          default(FALSE), not null
#  stripe_customer_guid :string
#  created_at           :datetime
#  updated_at           :datetime
#  logo_file_name       :string
#  logo_content_type    :string
#  logo_file_size       :integer
#  logo_updated_at      :datetime
#  subdomain            :string
#  user_name            :string
#  passcode             :string
#  external_url         :string
#  footer_border_colour :string           default("#EFF3F6")
#

FactoryGirl.define do
  factory :corporate_customer do
    sequence(:organisation_name)  {|n| "Customer #{n}"}
    address                       'MyText'
    country_id                    1 # todo { Country.first.try(:id) || 1 }
    payments_by_card              false
    stripe_customer_guid          'MyString'
    sequence(:subdomain)  {|n| "corp#{n}"}
    user_name          'MyString'
    passcode          'MyString'
  end

end
