class AddColumns < ActiveRecord::Migration[5.2]
  def change
    add_index :cbe_question_statuses, :name, unique: true
    add_index :cbe_section_types, :name, unique: true
  end
end
