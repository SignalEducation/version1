class RemoveUnusedCbesTables < ActiveRecord::Migration[5.2]
  def change
    drop_table :cbe_agreements
    drop_table :cbe_question_groupings
    drop_table :cbe_question_statuses
    drop_table :cbe_question_types
    drop_table :cbe_section_types
  end
end
