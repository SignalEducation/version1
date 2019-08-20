class AddNameAndDescriptionFieldsToCbeMultipleChoiceQuestion < ActiveRecord::Migration[5.2]
  def change
    add_column :cbe_multiple_choice_questions, :name, :string
    add_column :cbe_multiple_choice_questions, :description, :string
  end
end
