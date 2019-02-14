class AddTutorIdToExamLevels < ActiveRecord::Migration[4.2]
  def change
    add_column :exam_levels, :tutor_id, :integer, index: true
  end
end
