class AddExamLevelIdToQuizQuestion < ActiveRecord::Migration[4.2]
  def change
    add_column :quiz_questions, :exam_level_id, :integer
  end
end
