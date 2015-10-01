class CreateCorporateRequests < ActiveRecord::Migration
  def change
    create_table :corporate_requests do |t|
      t.string :name, index: true
      t.string :title
      t.string :company, index: true
      t.string :email, index: true
      t.string :phone_number, index: true
      t.string :website
      t.text :personal_message

      t.timestamps null: false
    end
  end
end
