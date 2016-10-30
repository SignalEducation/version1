# == Schema Information
#
# Table name: mock_exams
#
#  id                :integer          not null, primary key
#  subject_course_id :integer
#  product_id        :integer
#  name              :string
#  sorting_order     :integer
#  created_at        :datetime         not null
#  updated_at        :datetime         not null
#  file_file_name    :string
#  file_content_type :string
#  file_file_size    :integer
#  file_updated_at   :datetime
#

FactoryGirl.define do
  factory :mock_exam do
    subject_course_id 1
    product_id 1
    name "MyString"
    sorting_order 1
  end

end
