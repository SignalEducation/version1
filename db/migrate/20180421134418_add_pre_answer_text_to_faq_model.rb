class AddPreAnswerTextToFaqModel < ActiveRecord::Migration[4.2]
  def change
    add_column :faqs, :pre_answer_text, :text
  end
end
