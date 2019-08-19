class CreateCbeSectionTypes < ActiveRecord::Migration[5.2]
  def change
    create_table :cbe_section_types do |t|
      t.string :name

      t.timestamps
    end
  end
end
