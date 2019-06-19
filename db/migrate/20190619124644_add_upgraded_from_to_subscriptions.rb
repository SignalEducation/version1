class AddUpgradedFromToSubscriptions < ActiveRecord::Migration[5.2]
  def change
    add_reference :subscriptions, :changed_from, references: :subscriptions, foreign_key: { to_table: :subscriptions }
  end
end
