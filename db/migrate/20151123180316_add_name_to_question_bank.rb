class AddNameToQuestionBank < ActiveRecord::Migration[4.2]
  def change
    add_column :question_banks, :name, :string, index: true
    add_column :question_banks, :active, :boolean, default: false, index: true
  end
end
