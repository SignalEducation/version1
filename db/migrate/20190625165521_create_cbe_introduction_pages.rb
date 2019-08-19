class CreateCbeIntroductionPages < ActiveRecord::Migration[5.2]
  def change
    create_table :cbe_introduction_pages do |t|
      t.integer :number
      t.text :content
      t.string :title
      t.boolean :active

      t.timestamps
    end
  end
end
