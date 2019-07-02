class ChangeColumn < ActiveRecord::Migration[5.2]
  def change

    remove_column :cbe_question_statuses, :name
    remove_column :cbe_section_types, :name
  end
end
