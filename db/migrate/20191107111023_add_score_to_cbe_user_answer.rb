class AddScoreToCbeUserAnswer < ActiveRecord::Migration[5.2]
  def change
    add_column :cbe_user_answers, :score, :float, default: 0.0
  end
end
