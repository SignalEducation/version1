class AddCbeToCbeSection < ActiveRecord::Migration[5.2]
  def change
    add_reference :cbe_sections, :cbe, foreign_key: true
  end
end
