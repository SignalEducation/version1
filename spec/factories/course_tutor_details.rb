# == Schema Information
#
# Table name: course_tutor_details
#
#  id                :integer          not null, primary key
#  subject_course_id :integer
#  user_id           :integer
#  sorting_order     :integer
#  title             :string
#  created_at        :datetime         not null
#  updated_at        :datetime         not null
#

FactoryBot.define do
  factory :course_tutor_detail do
    subject_course_id { 1 }
    user_id { 1 }
    sorting_order { 1 }
    title { "MyString" }
  end
end
