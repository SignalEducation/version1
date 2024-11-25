class CreateCbeExhibits < ActiveRecord::Migration[5.2]
  def change
    create_table :cbe_exhibits do |t|
      t.string :name
      t.integer :kind
      t.json :content
      t.integer :sorting_order
      t.attachment :document

      t.timestamps
    end

    add_reference :cbe_exhibits, :cbe_scenario, index: true
  end
end
