class AddUnsubscribedFromEmailsToUserModel < ActiveRecord::Migration
  def change
    add_column :users, :unsubscribed_from_emails, :boolean, default: false
  end
end
