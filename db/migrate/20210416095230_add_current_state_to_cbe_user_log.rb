class AddCurrentStateToCbeUserLog < ActiveRecord::Migration[5.2]
  def change
    add_column :cbe_user_logs, :current_state, :string
  end
end
