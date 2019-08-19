class RenameColumn < ActiveRecord::Migration[5.2]
  def change
    rename_column :cbes, :desciption, :description
  end
end
