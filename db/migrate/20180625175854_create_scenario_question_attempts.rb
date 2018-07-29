class CreateScenarioQuestionAttempts < ActiveRecord::Migration
  def change
    create_table :scenario_question_attempts do |t|
      t.integer :constructed_response_attempt_id
      t.integer :course_module_element_user_log_id
      t.integer :user_id
      t.integer :constructed_response_id, index: true
      t.integer :scenario_question_id, index: true
      t.string :status
      t.boolean :flagged_for_review, default: false, index: true
      t.text :original_scenario_question_text
      t.text :user_edited_scenario_question_text

      t.timestamps null: false
    end
  end
end
