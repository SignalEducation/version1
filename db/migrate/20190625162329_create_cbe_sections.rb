class CreateCbeSections < ActiveRecord::Migration[5.2]
  def change
    create_table :cbe_sections do |t|
      t.string :name
      t.references :cbes
      t.text :scenario_description
      t.text :question_description
      t.string :scenario_label
      t.string :question_label

      t.timestamps
    end
  end
end
