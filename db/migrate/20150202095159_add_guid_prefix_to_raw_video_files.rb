class AddGuidPrefixToRawVideoFiles < ActiveRecord::Migration
  def change
    add_column :raw_video_files, :guid_prefix, :string
  end
end
