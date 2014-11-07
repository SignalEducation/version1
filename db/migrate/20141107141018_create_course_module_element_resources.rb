class CreateCourseModuleElementResources < ActiveRecord::Migration
  def change
    create_table :course_module_element_resources do |t|
      t.integer :course_module_element_id, index: true
      t.string :name
      t.text :description
      t.string :web_url

      t.timestamps
    end
  end
end
