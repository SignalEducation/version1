class AddStateToSubscriptions < ActiveRecord::Migration
  def change
    add_column :subscriptions, :state, :string
    rename_column :subscriptions, :current_status, :stripe_status
  end
end
