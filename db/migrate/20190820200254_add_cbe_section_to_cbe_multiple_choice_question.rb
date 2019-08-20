class AddCbeSectionToCbeMultipleChoiceQuestion < ActiveRecord::Migration[5.2]
  def change
    add_reference :cbe_multiple_choice_questions, :cbe_section, foreign_key: true
  end
end
