class CreateCourseModuleElementResources < ActiveRecord::Migration
  def change
    create_table :course_module_element_resources do |t|
      t.integer :course_module_element_id
      t.string :name
      t.text :description
      t.string :web_url

      t.timestamps
    end
    add_index :course_module_element_resources, :course_module_element_id, name: 'cme_resources_cme_id'
  end
end
