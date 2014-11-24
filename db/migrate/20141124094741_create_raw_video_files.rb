class CreateRawVideoFiles < ActiveRecord::Migration
  def change
    create_table :raw_video_files do |t|
      t.string :file_name, index: true
      t.integer :course_module_element_video_id, index: true
      t.boolean :transcode_requested, default: false, null: false

      t.timestamps
    end
  end
end
