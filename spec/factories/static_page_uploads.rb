# == Schema Information
#
# Table name: static_page_uploads
#
#  id                  :integer          not null, primary key
#  description         :string(255)
#  static_page_id      :integer
#  created_at          :datetime
#  updated_at          :datetime
#  upload_file_name    :string(255)
#  upload_content_type :string(255)
#  upload_file_size    :integer
#  upload_updated_at   :datetime
#

FactoryGirl.define do
  factory :static_page_upload do
    description "MyString"
static_page_id 1
  end

end
