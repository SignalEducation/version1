class AddGuidToMessages < ActiveRecord::Migration[5.2]
  def change
    add_column :messages, :guid, :string
  end
end
