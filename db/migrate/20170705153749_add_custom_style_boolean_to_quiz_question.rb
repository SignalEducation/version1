class AddCustomStyleBooleanToQuizQuestion < ActiveRecord::Migration
  def change
    add_column :quiz_questions, :custom_styles, :boolean, default: :false
  end
end
