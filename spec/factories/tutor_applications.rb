# == Schema Information
#
# Table name: tutor_applications
#
#  id          :integer          not null, primary key
#  first_name  :string
#  last_name   :string
#  email       :string
#  info        :text
#  description :text
#  created_at  :datetime         not null
#  updated_at  :datetime         not null
#

FactoryGirl.define do
  factory :tutor_application do
    first_name "MyString"
last_name "MyString"
email "MyString"
info "MyText"
description "MyText"
  end

end
