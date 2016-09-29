class CreateStudentUserTypes < ActiveRecord::Migration
  def change
    create_table :student_user_types do |t|
      t.string :name, index: true
      t.text :description
      t.boolean :subscription, default: false, index: true
      t.boolean :product_order, default: false, index: true

      t.timestamps null: false
    end
  end
end
