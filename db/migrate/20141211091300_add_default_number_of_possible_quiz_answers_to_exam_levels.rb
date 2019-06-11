class AddDefaultNumberOfPossibleQuizAnswersToExamLevels < ActiveRecord::Migration[4.2]
  def change
    add_column :exam_levels, :default_number_of_possible_exam_answers, :integer, default: 4
  end
end
