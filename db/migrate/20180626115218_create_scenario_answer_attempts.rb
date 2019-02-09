class CreateScenarioAnswerAttempts < ActiveRecord::Migration[4.2]
  def change
    create_table :scenario_answer_attempts do |t|
      t.integer :scenario_question_attempt_id
      t.integer :constructed_response_attempt_id
      t.integer :course_module_element_user_log_id
      t.integer :user_id
      t.integer :scenario_question_id
      t.integer :constructed_response_id
      t.integer :scenario_answer_template_id
      t.text :original_answer_template_text
      t.text :user_edited_answer_template_text
      t.string :editor_type

      t.timestamps null: false
    end
  end
end
