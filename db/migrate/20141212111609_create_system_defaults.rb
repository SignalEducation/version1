class CreateSystemDefaults < ActiveRecord::Migration[4.2]
  def change
    create_table :system_defaults do |t|
      t.integer :individual_student_user_group_id, index: true
      t.integer :corporate_student_user_group_id, index: true
      t.integer :corporate_customer_user_group_id, index: true

      t.timestamps
    end
  end
end
