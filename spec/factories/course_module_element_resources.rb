# == Schema Information
#
# Table name: course_module_element_resources
#
#  id                       :integer          not null, primary key
#  course_module_element_id :integer
#  name                     :string
#  description              :text
#  web_url                  :string
#  created_at               :datetime
#  updated_at               :datetime
#  upload_file_name         :string
#  upload_content_type      :string
#  upload_file_size         :integer
#  upload_updated_at        :datetime
#  destroyed_at             :datetime
#

FactoryGirl.define do
  factory :course_module_element_resource do
    course_module_element_id 1
    name 'MyString'
    description 'MyText'
    web_url 'https://linkedin.com'
  end

end
