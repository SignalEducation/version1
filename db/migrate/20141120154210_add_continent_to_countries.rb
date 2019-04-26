class AddContinentToCountries < ActiveRecord::Migration[4.2]
  def change
    add_column :countries, :continent, :string, index: true
  end
end
