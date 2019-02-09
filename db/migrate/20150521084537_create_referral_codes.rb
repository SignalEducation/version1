class CreateReferralCodes < ActiveRecord::Migration[4.2]
  def change
    create_table :referral_codes do |t|
      t.integer :user_id, index: true
      t.string :code, limit: 7

      t.timestamps null: false
    end
  end
end
