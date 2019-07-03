class ChangeColumn < ActiveRecord::Migration[5.2]
  def change

    remove_column :cbe_question_statuses, :cbes_id
    remove_column :cbe_question_statuses, :cbe_section_id
  end
end
