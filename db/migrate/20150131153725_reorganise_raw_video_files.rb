class ReorganiseRawVideoFiles < ActiveRecord::Migration
  def up
    remove_column :raw_video_files, :transcode_requested
    remove_column :raw_video_files, :course_module_element_video_id
    add_column :raw_video_files, :transcode_requested_at, :datetime
    add_column :raw_video_files, :transcode_request_guid, :string
    add_column :raw_video_files, :transcode_result, :string
    add_column :raw_video_files, :transcode_completed_at, :datetime
    add_column :raw_video_files, :raw_file_modified_at, :datetime
    add_column :raw_video_files, :aws_etag, :string
  end

  def down
    add_column :raw_video_files, :transcode_requested, :boolean, default: false
    add_column :raw_video_files, :course_module_element_video_id, :integer
    remove_column :raw_video_files, :transcode_requested_at
    remove_column :raw_video_files, :transcode_request_guid
    remove_column :raw_video_files, :transcode_result
    remove_column :raw_video_files, :transcode_completed_at
    remove_column :raw_video_files, :raw_file_modified_at
    remove_column :raw_video_files, :aws_etag
  end
end
