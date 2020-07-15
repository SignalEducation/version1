class CreateCbeRequirements < ActiveRecord::Migration[5.2]
  def change
    create_table :cbe_requirements do |t|
      t.string :name
      t.string :content
      t.float :score
      t.integer :sorting_order
      t.integer :kind

      t.timestamps
    end

    add_reference :cbe_requirements, :cbe_section, index: true
    add_reference :cbe_requirements, :cbe_scenario, index: true
  end
end
