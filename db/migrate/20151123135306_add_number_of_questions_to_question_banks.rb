class AddNumberOfQuestionsToQuestionBanks < ActiveRecord::Migration
  def change
    add_column :question_banks, :number_of_questions, :integer

    remove_column :question_banks, :user_id, :integer
    remove_column :question_banks, :exam_level_id, :integer
    remove_column :question_banks, :exam_section_id, :integer
    remove_column :question_banks, :easy_questions, :integer
    remove_column :question_banks, :medium_questions, :integer
    remove_column :question_banks, :hard_questions, :integer
  end
end
