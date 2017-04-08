class AddUsernameToUserModel < ActiveRecord::Migration
  def change
    add_column :users, :forum_username, :string, index: true
  end
end
