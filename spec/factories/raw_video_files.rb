# == Schema Information
#
# Table name: raw_video_files
#
#  id                     :integer          not null, primary key
#  file_name              :string
#  created_at             :datetime
#  updated_at             :datetime
#  transcode_requested_at :datetime
#  transcode_request_guid :string
#  transcode_result       :string
#  transcode_completed_at :datetime
#  raw_file_modified_at   :datetime
#  aws_etag               :string
#  duration_in_seconds    :integer          default(0)
#  guid_prefix            :string
#

FactoryGirl.define do
  factory :raw_video_file do
    file_name 'MyFilename.mp4'
    transcode_requested_at { Time.now }
    guid_prefix { "ABC#{rand(999999)}" }
  end

end
