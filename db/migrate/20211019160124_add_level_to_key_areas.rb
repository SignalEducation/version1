class AddLevelToKeyAreas < ActiveRecord::Migration[5.2]
  def change
    add_reference :key_areas, :level, index: true
  end
end
