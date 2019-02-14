class AddPhoneNumberToUserModel < ActiveRecord::Migration[4.2]
  def change
    add_column :users, :phone_number, :string, index: true
  end
end
