class CreateRefunds < ActiveRecord::Migration
  def change
    create_table :refunds do |t|
      t.string :stripe_guid
      t.integer :charge_id, index: true
      t.string :stripe_charge_guid
      t.integer :invoice_id, index: true
      t.integer :subscription_id, index: true
      t.integer :user_id, index: true
      t.integer :manager_id, index: true
      t.integer :amount
      t.text :reason
      t.string :status, index: true
      t.boolean :livemode, default: true
      t.text :stripe_refund_data

      t.timestamps null: false
    end
  end
end
