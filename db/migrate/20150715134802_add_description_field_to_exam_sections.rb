class AddDescriptionFieldToExamSections < ActiveRecord::Migration
  def change
    add_column :exam_sections, :description, :text
  end
end
