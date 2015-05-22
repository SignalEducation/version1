class AddReferralCodeIdToUser < ActiveRecord::Migration
  def change
    add_column :users, :referral_code_id, :integer
    add_index :users, :referral_code_id
  end
end
