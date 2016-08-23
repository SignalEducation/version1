class AddActiveBooleanToSubscriptions < ActiveRecord::Migration
  def change
    add_column :subscriptions, :active, :boolean, index: true, default: false
  end
end
