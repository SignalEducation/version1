# == Schema Information
#
# Table name: subject_course_resources
#
#  id                :integer          not null, primary key
#  name              :string
#  subject_course_id :integer
#  description       :text
#  created_at        :datetime         not null
#  updated_at        :datetime         not null
#

FactoryGirl.define do
  factory :subject_course_resource do
    name "MyString"
    subject_course_id 1
    description "MyText"
  end

end
