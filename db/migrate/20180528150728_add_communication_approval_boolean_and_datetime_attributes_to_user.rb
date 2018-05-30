class AddCommunicationApprovalBooleanAndDatetimeAttributesToUser < ActiveRecord::Migration
  def change
    add_column :users, :communication_approval, :boolean, default: false, index: true
    add_column :users, :communication_approval_datetime, :datetime
  end
end
