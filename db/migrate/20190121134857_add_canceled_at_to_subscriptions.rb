class AddCanceledAtToSubscriptions < ActiveRecord::Migration[4.2]
  def change
    add_column :subscriptions, :cancelled_at, :datetime
    add_column :subscriptions, :cancellation_reason, :string
    add_column :subscriptions, :cancellation_note, :text
  end
end
