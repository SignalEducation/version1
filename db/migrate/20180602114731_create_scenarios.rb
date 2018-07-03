class CreateScenarios < ActiveRecord::Migration
  def change
    create_table :scenarios do |t|
      t.integer :course_module_element_id, index: true
      t.integer :constructed_response_id, index: true
      t.integer :sorting_order
      t.text :text_content

      t.timestamps null: false
    end
  end
end
