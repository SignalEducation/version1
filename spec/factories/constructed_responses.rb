# == Schema Information
#
# Table name: constructed_responses
#
#  id                       :integer          not null, primary key
#  course_step_id :integer
#  created_at               :datetime         not null
#  updated_at               :datetime         not null
#  time_allowed             :integer
#  destroyed_at             :datetime
#

FactoryBot.define do
  factory :constructed_response do
    course_step_id { 1 }
  end
end
