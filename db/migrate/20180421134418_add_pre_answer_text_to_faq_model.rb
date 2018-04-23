class AddPreAnswerTextToFaqModel < ActiveRecord::Migration
  def change
    add_column :faqs, :pre_answer_text, :text
  end
end
