class AddEnableExamSectionsToExamLevels < ActiveRecord::Migration
  def change
    add_column :exam_levels, :enable_exam_sections, :boolean, default: true, null: false, index: true
  end
end
