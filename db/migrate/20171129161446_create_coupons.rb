class CreateCoupons < ActiveRecord::Migration
  def change
    create_table :coupons do |t|
      t.string :name, index: true
      t.string :code, index: true
      t.integer :currency_id
      t.boolean :livemode, default: false
      t.boolean :active, default: false, index: true
      t.integer :amount_off
      t.string :duration
      t.integer :duration_in_months
      t.integer :max_redemptions
      t.integer :percent_off
      t.datetime :redeem_by
      t.integer :times_redeemed

      t.timestamps null: false
    end
  end
end
