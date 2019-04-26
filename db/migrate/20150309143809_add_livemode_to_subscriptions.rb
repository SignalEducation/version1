class AddLivemodeToSubscriptions < ActiveRecord::Migration[4.2]
  def change
    add_column :subscriptions, :livemode, :boolean, default: false
  end
end
