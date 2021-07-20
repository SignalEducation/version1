class CreateBearers < ActiveRecord::Migration[5.2]
  def change
    create_table :bearers do |t|
      t.string  :name, null: false
      t.string  :slug, null: false
      t.string  :api_key, null: false
      t.integer :status, null: false, default: 0

      t.timestamps
    end
  end
end
