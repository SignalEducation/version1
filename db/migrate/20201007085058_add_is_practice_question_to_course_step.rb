class AddIsPracticeQuestionToCourseStep < ActiveRecord::Migration[5.2]
  def change
    add_column :course_steps, :is_practice_question, :boolean
  end
end
