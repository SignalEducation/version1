class CreateSystemSettings < ActiveRecord::Migration[5.2]
  def change
    enable_extension 'hstore'

    create_table :system_settings do |t|
      t.string :environment, unique: true
      t.hstore :settings

      t.timestamps
    end
  end
end
