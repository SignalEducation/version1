class CreateVideoResources < ActiveRecord::Migration
  def change
    create_table :video_resources do |t|
      t.integer :course_module_element_id, index: true
      t.text :question
      t.text :answer
      t.text :notes
      t.datetime :destroyed_at

      t.timestamps null: false
    end
  end
end
