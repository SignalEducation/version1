class AddPhoneNumberToUserModel < ActiveRecord::Migration
  def change
    add_column :users, :phone_number, :string, index: true
  end
end
