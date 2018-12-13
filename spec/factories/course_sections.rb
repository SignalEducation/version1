# == Schema Information
#
# Table name: course_sections
#
#  id                        :integer          not null, primary key
#  subject_course_id         :integer
#  name                      :string
#  name_url                  :string
#  sorting_order             :integer
#  active                    :boolean          default(FALSE)
#  counts_towards_completion :boolean          default(FALSE)
#  assumed_knowledge         :boolean          default(FALSE)
#  created_at                :datetime         not null
#  updated_at                :datetime         not null
#

FactoryBot.define do
  factory :course_sections do
    subject_course_id 1
    name "MyString"
    name_url "MyString"
    sorting_order 1
    active false
    counts_towards_completion false
    assumed_knowledge false
  end
end
