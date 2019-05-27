class AddBackgroundColourCodeToInstitutions < ActiveRecord::Migration[4.2]
  def change
    add_column :institutions, :background_colour_code, :string
  end
end
