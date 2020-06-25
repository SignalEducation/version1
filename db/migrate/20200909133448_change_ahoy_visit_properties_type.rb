class ChangeAhoyVisitPropertiesType < ActiveRecord::Migration[5.2]
  def change
    change_column :ahoy_events, :properties, :jsonb, using: 'properties::text::jsonb'
  end
end
