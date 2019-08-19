class AddRelationshipsToIntroductionPages < ActiveRecord::Migration[5.2]
  def change
    add_reference :cbe_questions, :cbe_question, foreign_key: true
  end
end
