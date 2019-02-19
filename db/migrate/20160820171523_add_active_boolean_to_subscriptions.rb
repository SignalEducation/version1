class AddActiveBooleanToSubscriptions < ActiveRecord::Migration[4.2]
  def change
    add_column :subscriptions, :active, :boolean, index: true, default: false
  end
end
