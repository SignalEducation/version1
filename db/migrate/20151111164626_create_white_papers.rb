class CreateWhitePapers < ActiveRecord::Migration
  def change
    create_table :white_papers do |t|
      t.string :title, index: true
      t.text :description

      t.timestamps null: false
    end
  end
end
