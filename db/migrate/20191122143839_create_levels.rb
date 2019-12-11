class CreateLevels < ActiveRecord::Migration[5.2]
  def change
    create_table :levels do |t|
      t.integer :group_id, index: true
      t.string :name
      t.string :name_url
      t.boolean :active, default: false, null: false
      t.string :highlight_colour, default: "#ef475d"
      t.integer :sorting_order
      t.string :icon_label

      t.timestamps
    end

    add_column :subject_courses, :level_id, :integer
  end
end
