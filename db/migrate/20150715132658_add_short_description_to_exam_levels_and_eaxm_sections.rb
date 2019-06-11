class AddShortDescriptionToExamLevelsAndEaxmSections < ActiveRecord::Migration[4.2]
  def change
    add_column :exam_levels, :short_description, :text
    add_column :exam_sections, :short_description, :text
  end
end
