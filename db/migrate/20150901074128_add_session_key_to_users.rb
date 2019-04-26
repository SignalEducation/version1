class AddSessionKeyToUsers < ActiveRecord::Migration[4.2]
  def change
    add_column :users, :session_key, :string
  end
end
