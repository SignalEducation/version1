class CreateCbeResponseOptions < ActiveRecord::Migration[5.2]
  def change
    create_table :cbe_response_options do |t|
      t.integer :kind
      t.integer :quantity
      t.integer :sorting_order

      t.timestamps
    end

    add_reference :cbe_response_options, :cbe_scenario, index: true
  end
end
