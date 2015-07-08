class AddTutorIdToExamLevels < ActiveRecord::Migration
  def change
    add_column :exam_levels, :tutor_id, :integer, index: true
  end
end
