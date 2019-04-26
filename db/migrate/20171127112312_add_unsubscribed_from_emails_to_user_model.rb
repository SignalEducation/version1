class AddUnsubscribedFromEmailsToUserModel < ActiveRecord::Migration[4.2]
  def change
    add_column :users, :unsubscribed_from_emails, :boolean, default: false
  end
end
