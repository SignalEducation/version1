class AddDescriptionFieldToExamSections < ActiveRecord::Migration[4.2]
  def change
    add_column :exam_sections, :description, :text
  end
end
