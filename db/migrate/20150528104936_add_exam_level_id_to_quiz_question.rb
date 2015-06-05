class AddExamLevelIdToQuizQuestion < ActiveRecord::Migration
  def change
    add_column :quiz_questions, :exam_level_id, :integer
  end
end
