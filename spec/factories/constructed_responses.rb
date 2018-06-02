# == Schema Information
#
# Table name: constructed_responses
#
#  id                       :integer          not null, primary key
#  course_module_element_id :integer
#  created_at               :datetime         not null
#  updated_at               :datetime         not null
#  time_allowed             :integer
#

FactoryBot.define do
  factory :constructed_response do
    course_module_element_id 1
  end
end
