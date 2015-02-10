class AddDurationInSecondsToRawVideoFiles < ActiveRecord::Migration
  def change
    add_column :raw_video_files, :duration_in_seconds, :integer, default: 0
  end
end
