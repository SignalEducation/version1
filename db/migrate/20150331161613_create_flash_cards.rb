class CreateFlashCards < ActiveRecord::Migration
  def change
    create_table :flash_cards do |t|
      t.integer :flash_card_stack_id, index: true
      t.integer :sorting_order, index: true

      t.timestamps
    end
  end
end
