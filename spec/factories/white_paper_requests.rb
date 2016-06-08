# == Schema Information
#
# Table name: white_paper_requests
#
#  id             :integer          not null, primary key
#  name           :string
#  email          :string
#  number         :string
#  company_name   :string
#  white_paper_id :integer
#  created_at     :datetime         not null
#  updated_at     :datetime         not null
#

FactoryGirl.define do
  factory :white_paper_request do
    name "MyString"
    email "MyString"
    number "MyString"
    company_name "MyString"
    white_paper_id 1
  end

end
