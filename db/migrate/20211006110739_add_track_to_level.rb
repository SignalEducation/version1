class AddTrackToLevel < ActiveRecord::Migration[5.2]
  def change
    add_column :levels, :track, :boolean, default: false, null: false
  end
end
