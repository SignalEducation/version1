class AddEmailVerificationFieldsToUserModel < ActiveRecord::Migration
  def change
    add_column :users, :email_verification_code, :string, index: true
    add_column :users, :email_verified_at, :datetime
    add_column :users, :email_verified, :boolean, index: true, default: false, null: false
  end
end
