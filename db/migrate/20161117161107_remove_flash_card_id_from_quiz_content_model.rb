class RemoveFlashCardIdFromQuizContentModel < ActiveRecord::Migration
  def change
    remove_column :quiz_contents, :flash_card_id, :integer
    remove_column :quiz_questions, :flash_quiz_id, :integer
  end
end
