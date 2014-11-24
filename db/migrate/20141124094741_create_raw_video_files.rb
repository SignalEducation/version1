class CreateRawVideoFiles < ActiveRecord::Migration
  def change
    create_table :raw_video_files do |t|
      t.string :file_name
      t.integer :course_module_element_video_id
      t.boolean :transcode_requested

      t.timestamps
    end
  end
end
