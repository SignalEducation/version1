class AddCompletionGuidToSubscriptions < ActiveRecord::Migration[5.2]
  def change
    add_column :subscriptions, :completion_guid, :string
  end
end
