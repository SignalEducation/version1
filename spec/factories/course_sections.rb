# == Schema Information
#
# Table name: course_sections
#
#  id                         :integer          not null, primary key
#  course_id                  :integer
#  name                       :string
#  name_url                   :string
#  sorting_order              :integer
#  active                     :boolean          default("false")
#  counts_towards_completion  :boolean          default("false")
#  assumed_knowledge          :boolean          default("false")
#  created_at                 :datetime         not null
#  updated_at                 :datetime         not null
#  cme_count                  :integer          default("0")
#  video_count                :integer          default("0")
#  quiz_count                 :integer          default("0")
#  destroyed_at               :datetime
#  constructed_response_count :integer          default("0")
#

FactoryBot.define do
  factory :course_section do
    course_id                 { 1 }
    name                      { 'Course Section' }
    sequence(:name_url)       { |x| "course-section-#{x}" }
    sequence(:sorting_order)  { |n| n * 100 }
    active                    { true }
    counts_towards_completion { false }
    assumed_knowledge         { false }
    course
  end
end
