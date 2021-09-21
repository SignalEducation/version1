class AddLastTimeShowedToUser < ActiveRecord::Migration[5.2]
  def change
    add_column :users, :verify_remembered_at, :datetime
  end
end