class CreateQuizAttempts < ActiveRecord::Migration
  def change
    create_table :quiz_attempts do |t|
      t.integer :user_id, index: true
      t.integer :quiz_question_id, index: true
      t.integer :quiz_answer_id, index: true
      t.boolean :correct, default: false, null: false
      t.integer :course_module_element_user_log_id, index: true

      t.timestamps
    end
  end
end
