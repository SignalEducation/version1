class AddDefaultNumberOfPossibleQuizAnswersToExamLevels < ActiveRecord::Migration
  def change
    add_column :exam_levels, :default_number_of_possible_exam_answers, :integer, default: 4
  end
end
