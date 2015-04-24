# == Schema Information
#
# Table name: course_module_element_resources
#
#  id                       :integer          not null, primary key
#  course_module_element_id :integer
#  name                     :string(255)
#  description              :text
#  web_url                  :string(255)
#  created_at               :datetime
#  updated_at               :datetime
#  upload_file_name         :string(255)
#  upload_content_type      :string(255)
#  upload_file_size         :integer
#  upload_updated_at        :datetime
#  destroyed_at             :datetime
#

FactoryGirl.define do
  factory :course_module_element_resource do
    course_module_element_id 1
    name "MyString"
    description "MyText"
    web_url "MyString"
  end

end
