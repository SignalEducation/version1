class AddPagesStateToCbeUserLog < ActiveRecord::Migration[5.2]
  def change
    add_column :cbe_user_logs, :pages_state, :json
  end
end
