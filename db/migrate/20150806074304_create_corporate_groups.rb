class CreateCorporateGroups < ActiveRecord::Migration
  def change
    create_table :corporate_groups do |t|
      t.integer :corporate_customer_id, index: true
      t.string :name

      t.timestamps null: false
    end
  end
end
