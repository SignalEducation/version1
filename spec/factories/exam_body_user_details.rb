# == Schema Information
#
# Table name: exam_body_user_details
#
#  id             :integer          not null, primary key
#  user_id        :integer
#  exam_body_id   :integer
#  student_number :string
#  created_at     :datetime         not null
#  updated_at     :datetime         not null
#

FactoryBot.define do
  factory :exam_body_user_detail do
    user_id { 1 }
    exam_body_id { 1 }
    student_number { "MyString" }
  end
end
