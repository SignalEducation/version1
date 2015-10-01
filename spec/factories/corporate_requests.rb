# == Schema Information
#
# Table name: corporate_requests
#
#  id               :integer          not null, primary key
#  name             :string
#  title            :string
#  company          :string
#  email            :string
#  phone_number     :string
#  website          :string
#  personal_message :text
#  created_at       :datetime         not null
#  updated_at       :datetime         not null
#

FactoryGirl.define do
  factory :corporate_request do
    name 'MyString'
    title 'MyString'
    company 'MyString'
    email 'MyString'
    phone_number 'MyString'
    website 'MyString'
    personal_message 'MyText'
  end

end
