class CreateCorporateCustomers < ActiveRecord::Migration
  def change
    create_table :corporate_customers do |t|
      t.string :organisation_name
      t.text :address
      t.integer :country_id, index: true
      t.boolean :payments_by_card, default: false, null: false
      t.boolean :is_university, default: false, null: false
      t.integer :owner_id, index: true
      t.string :stripe_customer_guid, index: true
      t.boolean :can_restrict_content, default: false, null: false

      t.timestamps
    end
  end
end
