# == Schema Information
#
# Table name: raw_video_files
#
#  id                     :integer          not null, primary key
#  file_name              :string(255)
#  created_at             :datetime
#  updated_at             :datetime
#  transcode_requested_at :datetime
#  transcode_request_guid :string(255)
#  transcode_result       :string(255)
#  transcode_completed_at :datetime
#  raw_file_modified_at   :datetime
#  aws_etag               :string(255)
#  duration_in_seconds    :integer          default(0)
#  guid_prefix            :string(255)
#

FactoryGirl.define do
  factory :raw_video_file do
    file_name 'MyFilename.mp4'
    transcode_requested_at { Time.now }
    guid_prefix { "ABC#{rand(999999)}" }
  end

end
