class MakeGroupingsUnique < ActiveRecord::Migration[5.2]
  def change
    add_index :cbe_question_groupings, [:cbe_id, :cbe_section_id], :unique => true
  end
end
