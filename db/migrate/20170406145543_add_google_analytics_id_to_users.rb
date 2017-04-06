class AddGoogleAnalyticsIdToUsers < ActiveRecord::Migration
  def change
    add_column :users, :analytics_guid, :string
  end
end
