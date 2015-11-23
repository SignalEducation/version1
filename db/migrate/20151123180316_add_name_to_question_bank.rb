class AddNameToQuestionBank < ActiveRecord::Migration
  def change
    add_column :question_banks, :name, :string, index: true
    add_column :question_banks, :active, :boolean, default: false, index: true
  end
end
