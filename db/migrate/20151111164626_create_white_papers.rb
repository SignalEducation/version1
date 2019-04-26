class CreateWhitePapers < ActiveRecord::Migration[4.2]
  def change
    create_table :white_papers do |t|
      t.string :title, index: true
      t.text :description

      t.timestamps null: false
    end
  end
end
