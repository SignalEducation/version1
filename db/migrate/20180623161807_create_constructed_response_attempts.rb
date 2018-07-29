class CreateConstructedResponseAttempts < ActiveRecord::Migration
  def change
    create_table :constructed_response_attempts do |t|
      t.integer :constructed_response_id, index: true
      t.integer :scenario_id, index: true
      t.integer :course_module_element_id, index: true
      t.integer :course_module_element_user_log_id
      t.integer :user_id, index: true
      t.text :original_scenario_text_content
      t.text :user_edited_scenario_text_content
      t.string :status
      t.boolean :flagged_for_review, default: false, index: true
      t.integer :time_in_seconds

      t.timestamps null: false
    end
  end
end
