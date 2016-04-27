class AddColourFieldToGroups < ActiveRecord::Migration
  def change
    add_column :groups, :background_colour, :string
  end
end
