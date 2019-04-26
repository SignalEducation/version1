class CreateFlashCards < ActiveRecord::Migration[4.2]
  def change
    create_table :flash_cards do |t|
      t.integer :flash_card_stack_id, index: true
      t.integer :sorting_order, index: true

      t.timestamps
    end
  end
end
