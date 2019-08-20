class DropCbeQuestionGroupingFromCbeMultipleChoiceQuestion < ActiveRecord::Migration[5.2]
  def change
    remove_column :cbe_multiple_choice_questions, :cbe_question_grouping_id
  end
end
