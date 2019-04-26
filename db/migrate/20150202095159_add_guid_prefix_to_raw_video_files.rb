class AddGuidPrefixToRawVideoFiles < ActiveRecord::Migration[4.2]
  def change
    add_column :raw_video_files, :guid_prefix, :string
  end
end
