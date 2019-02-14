class RemoveStripeDevCall < ActiveRecord::Migration[4.2]
  def change
    drop_table :stripe_developer_calls
  end
end
