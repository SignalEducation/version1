class AddBackgroundColourCodeToInstitutions < ActiveRecord::Migration
  def change
    add_column :institutions, :background_colour_code, :string
  end
end
