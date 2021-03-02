class AddAgreedToCbeUserLog < ActiveRecord::Migration[5.2]
  def change
    add_column :cbe_user_logs, :agreed, :boolean, default: false
  end
end
