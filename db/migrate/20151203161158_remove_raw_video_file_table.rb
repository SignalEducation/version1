class RemoveRawVideoFileTable < ActiveRecord::Migration[4.2]
  def change
    drop_table :raw_video_files
    remove_column :course_module_element_videos, :raw_video_file_id, :integer
  end
end
