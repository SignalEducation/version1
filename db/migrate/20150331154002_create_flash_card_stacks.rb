class CreateFlashCardStacks < ActiveRecord::Migration
  def change
    create_table :flash_card_stacks do |t|
      t.integer :course_module_element_flash_card_pack_id
      t.string :name
      t.integer :sorting_order
      t.string :final_button_label
      t.string :content_type

      t.timestamps
    end
    add_index :flash_card_stacks, :course_module_element_flash_card_pack_id, name: 'flash_card_stacks_cme_flash_card_pack_id'
  end
end
