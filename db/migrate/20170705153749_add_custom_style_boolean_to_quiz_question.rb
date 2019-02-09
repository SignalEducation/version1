class AddCustomStyleBooleanToQuizQuestion < ActiveRecord::Migration[4.2]
  def change
    add_column :quiz_questions, :custom_styles, :boolean, default: :false
  end
end
