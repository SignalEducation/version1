class ChangeMessageState < ActiveRecord::Migration[5.2]
  def change
    change_column :messages, :state, :string
  end
end
