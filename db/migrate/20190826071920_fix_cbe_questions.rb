class FixCbeQuestions < ActiveRecord::Migration[5.2]
  def change
    add_column    :cbe_questions, :kind, :integer
    remove_column :cbe_questions, :cbe_question_id, :integer
    add_reference :cbe_questions, :cbe_section, index: true
  end
end
