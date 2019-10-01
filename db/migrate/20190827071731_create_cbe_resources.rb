class CreateCbeResources < ActiveRecord::Migration[5.2]
  def change
    create_table :cbe_resources do |t|
      t.string :name
      t.integer :sorting_order
      t.attachment :document

      t.timestamps
    end

    add_reference :cbe_resources, :cbe, index: true
  end
end
