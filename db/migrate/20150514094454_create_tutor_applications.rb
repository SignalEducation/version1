class CreateTutorApplications < ActiveRecord::Migration
  def change
    create_table :tutor_applications do |t|
      t.string :first_name
      t.string :last_name
      t.string :email, index: true
      t.text :info
      t.text :description

      t.timestamps null: false
    end
  end
end
