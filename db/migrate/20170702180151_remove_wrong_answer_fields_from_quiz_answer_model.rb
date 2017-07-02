class RemoveWrongAnswerFieldsFromQuizAnswerModel < ActiveRecord::Migration
  def change
    remove_column :quiz_answers, :wrong_answer_explanation_text, :text
    remove_column :quiz_answers, :wrong_answer_video_id, :integer
    remove_column :quiz_contents, :contains_image, :boolean
    remove_column :quiz_contents, :contains_mathjax, :boolean
  end
end
