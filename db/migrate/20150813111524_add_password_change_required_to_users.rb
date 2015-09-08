class AddPasswordChangeRequiredToUsers < ActiveRecord::Migration
  def change
    add_column :users, :password_change_required, :boolean
  end
end
