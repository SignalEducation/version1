class CreatePracticeQuestionResponse < ActiveRecord::Migration[5.2]
  def change
    create_table :practice_question_responses do |t|
      t.integer :practice_question_id
      t.integer :sorting_order
      t.integer :kind
      t.json :content
      t.references :course_step_log, foreign_key: true, index: true

      t.timestamps
    end
  end
end
