class CreateFlashQuizzes < ActiveRecord::Migration
  def change
    create_table :flash_quizzes do |t|
      t.integer :flash_card_stack_id, index: true
      t.string :background_color
      t.string :foreground_color

      t.timestamps
    end
  end
end
