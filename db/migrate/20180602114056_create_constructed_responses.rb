class CreateConstructedResponses < ActiveRecord::Migration
  def change
    create_table :constructed_responses do |t|
      t.integer :course_module_element_id, index: true

      t.timestamps null: false
    end
  end
end
