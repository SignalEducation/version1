class AddGoogleAnalyticsIdToUsers < ActiveRecord::Migration[4.2]
  def change
    add_column :users, :analytics_guid, :string
  end
end
