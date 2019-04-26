class AddPasswordChangeRequiredToUsers < ActiveRecord::Migration[4.2]
  def change
    add_column :users, :password_change_required, :boolean
  end
end
