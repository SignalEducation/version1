class CreateFlashCardStacks < ActiveRecord::Migration
  def change
    create_table :flash_card_stacks do |t|
      t.integer :course_module_element_flash_card_pack_id, index: true
      t.string :name
      t.integer :sorting_order
      t.string :final_button_label
      t.string :content_type

      t.timestamps
    end
  end
end
