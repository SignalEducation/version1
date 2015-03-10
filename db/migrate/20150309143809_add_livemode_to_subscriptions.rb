class AddLivemodeToSubscriptions < ActiveRecord::Migration
  def change
    add_column :subscriptions, :livemode, :boolean, default: false
  end
end
