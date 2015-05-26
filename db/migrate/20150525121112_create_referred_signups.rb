class CreateReferredSignups < ActiveRecord::Migration
  def change
    create_table :referred_signups do |t|
      t.integer :referral_code_id, index: true
      t.integer :user_id, index: true
      t.string :referrer_url, limit: 2048
      t.integer :subscription_id, index: true
      t.datetime :maturing_on
      t.datetime :payed_at

      t.timestamps null: false
    end
  end
end
