# == Schema Information
#
# Table name: raw_video_files
#
#  id                             :integer          not null, primary key
#  file_name                      :string(255)
#  course_module_element_video_id :integer
#  transcode_requested            :boolean          default(FALSE), not null
#  created_at                     :datetime
#  updated_at                     :datetime
#

FactoryGirl.define do
  factory :raw_video_file do
    file_name 'MyString'
    course_module_element_video_id 1
    transcode_requested false
  end

end
