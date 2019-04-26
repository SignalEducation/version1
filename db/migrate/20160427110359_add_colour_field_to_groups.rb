class AddColourFieldToGroups < ActiveRecord::Migration[4.2]
  def change
    add_column :groups, :background_colour, :string
  end
end
