class ChangeMessageAttributes < ActiveRecord::Migration[5.2]
  def change
    remove_column :messages, :sent
    remove_column :messages, :bounced
    remove_column :messages, :rejected
    remove_column :messages, :marked_as_spam

    add_column :messages, :state, :integer

    rename_column :messages, :params, :url
    rename_column :messages, :opened, :opens
    rename_column :messages, :clicked, :clicks
  end
end
