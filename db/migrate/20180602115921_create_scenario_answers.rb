class CreateScenarioAnswers < ActiveRecord::Migration
  def change
    create_table :scenario_answers do |t|
      t.integer :course_module_element_id, index: true
      t.integer :constructed_response_id, index: true
      t.integer :scenario_id, index: true
      t.integer :scenario_question_id, index: true
      t.integer :sorting_order
      t.string :type

      t.timestamps null: false
    end
  end
end
