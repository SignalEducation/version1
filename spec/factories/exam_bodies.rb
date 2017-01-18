# == Schema Information
#
# Table name: exam_bodies
#
#  id         :integer          not null, primary key
#  name       :string
#  url        :string
#  created_at :datetime         not null
#  updated_at :datetime         not null
#

FactoryGirl.define do
  factory :exam_body do
    sequence(:name)           { |n| "Exam Body #{n}" }
    url "MyString"
  end

end
