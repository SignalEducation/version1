class AddCancelledByInSubscription < ActiveRecord::Migration[5.2]
  def change
    add_reference :subscriptions, :cancelled_by, index: true
  end
end
