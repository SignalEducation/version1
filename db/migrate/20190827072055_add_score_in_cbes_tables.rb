class AddScoreInCbesTables < ActiveRecord::Migration[5.2]
  def change
    add_column :cbes,          :score, :float
    add_column :cbe_sections,  :score, :float
    add_column :cbe_questions, :score, :float
  end
end
