class RemoveExtraParentIdsFromConstructedResponseModels < ActiveRecord::Migration
  def change
    remove_column :scenario_answer_templates, :course_module_element_id, :integer, index: true
    remove_column :scenario_answer_templates, :constructed_response_id, :integer, index: true
    remove_column :scenario_answer_templates, :scenario_id, :integer, index: true

    remove_column :scenario_questions, :course_module_element_id, :integer, index: true
    remove_column :scenario_questions, :constructed_response_id, :integer, index: true

    remove_column :scenarios, :course_module_element_id, :integer, index: true
  end
end
