class CreateStudentUserTypes < ActiveRecord::Migration
  def up
    create_table :student_user_types do |t|
      t.string :name, index: true
      t.text :description
      t.boolean :subscription, default: false, index: true
      t.boolean :product_order, default: false, index: true

      t.timestamps null: false
    end

  end

  def down
    drop_table :student_user_types
  end

end
