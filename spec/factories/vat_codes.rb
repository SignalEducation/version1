# == Schema Information
#
# Table name: vat_codes
#
#  id         :integer          not null, primary key
#  country_id :integer
#  name       :string
#  label      :string
#  wiki_url   :string
#  created_at :datetime
#  updated_at :datetime
#

FactoryGirl.define do
  factory :vat_code do
    country_id 1
    name 'Standard'
    label 'VAT'
    wiki_url 'MyString'
  end

end
