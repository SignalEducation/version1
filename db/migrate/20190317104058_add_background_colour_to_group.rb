class AddBackgroundColourToGroup < ActiveRecord::Migration[5.2]
  def change
    add_column :groups, :background_colour, :string
  end
end
