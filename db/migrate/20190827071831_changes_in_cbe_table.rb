class ChangesInCbeTable < ActiveRecord::Migration[5.2]
  def change
    add_column    :cbes, :agreement_content, :text
    add_column    :cbes, :active, :boolean, default: false, null: false
    rename_column :cbes, :description, :content
  end
end
