class CreateInstitutionUsers < ActiveRecord::Migration
  def change
    create_table :institution_users do |t|
      t.integer :institution_id, index: true
      t.integer :user_id, index: true
      t.string :student_registration_number
      t.boolean :student, default: false, null: false
      t.boolean :qualified, default: false, null: false

      t.timestamps
    end
  end
end
