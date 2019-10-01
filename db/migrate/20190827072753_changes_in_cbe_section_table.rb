class ChangesInCbeSectionTable < ActiveRecord::Migration[5.2]
  def change
    add_column :cbe_sections, :kind,          :integer
    add_column :cbe_sections, :sorting_order, :integer
    add_column :cbe_sections, :content,       :text

    remove_column :cbe_sections, :question_label, :string
    remove_column :cbe_sections, :scenario_label, :string
    remove_column :cbe_sections, :question_description, :string
    remove_column :cbe_sections, :scenario_description, :string
  end
end
