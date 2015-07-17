class AddShortDescriptionToExamLevelsAndEaxmSections < ActiveRecord::Migration
  def change
    add_column :exam_levels, :short_description, :text
    add_column :exam_sections, :short_description, :text
  end
end
