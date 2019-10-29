# == Schema Information
#
# Table name: course_sections
#
#  id                         :integer          not null, primary key
#  subject_course_id          :integer
#  name                       :string
#  name_url                   :string
#  sorting_order              :integer
#  active                     :boolean          default(FALSE)
#  counts_towards_completion  :boolean          default(FALSE)
#  assumed_knowledge          :boolean          default(FALSE)
#  created_at                 :datetime         not null
#  updated_at                 :datetime         not null
#  cme_count                  :integer          default(0)
#  video_count                :integer          default(0)
#  quiz_count                 :integer          default(0)
#  destroyed_at               :datetime
#  constructed_response_count :integer          default(0)
#

FactoryBot.define do
  factory :course_section do
    subject_course_id { 1 }
    name { "MyString" }
    sequence(:name_url)  { |x| "course-section-#{x}" }
    sorting_order { 1 }
    active { true }
    counts_towards_completion { false }
    assumed_knowledge { false }
    subject_course
  end
end
