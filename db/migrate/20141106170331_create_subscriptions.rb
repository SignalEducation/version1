class CreateSubscriptions < ActiveRecord::Migration
  def change
    create_table :subscriptions do |t|
      t.integer :user_id, index: true
      t.integer :corporate_customer_id, index: true
      t.integer :subscription_plan_id, index: true
      t.string :stripe_guid
      t.date :next_renewal_date, index: true
      t.boolean :complementary, default: false, null: false
      t.string :current_status, index: true

      t.timestamps
    end
  end
end
