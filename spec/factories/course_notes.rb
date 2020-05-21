# == Schema Information
#
# Table name: course_notes
#
#  id                       :integer          not null, primary key
#  course_step_id :integer
#  name                     :string(255)
#  web_url                  :string(255)
#  created_at               :datetime
#  updated_at               :datetime
#  upload_file_name         :string(255)
#  upload_content_type      :string(255)
#  upload_file_size         :integer
#  upload_updated_at        :datetime
#  destroyed_at             :datetime
#

FactoryBot.define do
  factory :course_note do
    course_step_id  { 1 }
    sequence(:name) { |n| "Resource #{n}" }
    web_url         { 'https://linkedin.com' }
  end
end
