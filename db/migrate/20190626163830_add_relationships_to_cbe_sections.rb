class AddRelationshipsToCbeSections < ActiveRecord::Migration[5.2]
  def change
    def change
      add_reference :cbe_types, :cbe_type, foreign_key: true
      add_reference :cbe_questions, :cbe_question, foreign_key: true
    end
  end
end
