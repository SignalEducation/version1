class AddSubTextToLevel < ActiveRecord::Migration[5.2]
  def change
    add_column :levels, :sub_text, :text
  end
end
