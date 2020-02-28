# == Schema Information
#
# Table name: vat_codes
#
#  id         :integer          not null, primary key
#  country_id :integer
#  name       :string(255)
#  label      :string(255)
#  wiki_url   :string(255)
#  created_at :datetime
#  updated_at :datetime
#

FactoryBot.define do
  factory :vat_code do
    country
    name { 'Standard' }
    label { 'VAT' }
    wiki_url { 'MyString' }
  end
end
