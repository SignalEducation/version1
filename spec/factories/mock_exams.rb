# == Schema Information
#
# Table name: mock_exams
#
#  id                       :integer          not null, primary key
#  course_id                :integer
#  name                     :string
#  sorting_order            :integer
#  created_at               :datetime         not null
#  updated_at               :datetime         not null
#  file_file_name           :string
#  file_content_type        :string
#  file_file_size           :integer
#  file_updated_at          :datetime
#  cover_image_file_name    :string
#  cover_image_content_type :string
#  cover_image_file_size    :integer
#  cover_image_updated_at   :datetime
#

FactoryBot.define do
  factory :mock_exam do
    course
    name { "MyString" }
    sorting_order { 1 }
  end

end
