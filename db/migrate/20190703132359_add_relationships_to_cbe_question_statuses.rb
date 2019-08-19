class AddRelationshipsToCbeQuestionStatuses < ActiveRecord::Migration[5.2]
  def change
    add_reference :cbe_question_types, :cbe_question, foreign_key: true
  end
end
