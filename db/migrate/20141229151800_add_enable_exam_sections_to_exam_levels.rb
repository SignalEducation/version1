class AddEnableExamSectionsToExamLevels < ActiveRecord::Migration[4.2]
  def change
    add_column :exam_levels, :enable_exam_sections, :boolean, default: true, null: false, index: true
  end
end
