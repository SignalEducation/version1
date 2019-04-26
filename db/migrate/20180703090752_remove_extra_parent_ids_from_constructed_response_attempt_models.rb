class RemoveExtraParentIdsFromConstructedResponseAttemptModels < ActiveRecord::Migration[4.2]
  def change
    remove_column :scenario_answer_attempts, :constructed_response_attempt_id
    remove_column :scenario_answer_attempts, :course_module_element_user_log_id
    remove_column :scenario_answer_attempts, :scenario_question_id
    remove_column :scenario_answer_attempts, :constructed_response_id

    remove_column :scenario_question_attempts, :course_module_element_user_log_id
    remove_column :scenario_question_attempts, :constructed_response_id, index: true
  end
end
