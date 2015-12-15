class RemoveStripeDevCall < ActiveRecord::Migration
  def change
    drop_table :stripe_developer_calls
  end
end
