class RemoveFlashCards < ActiveRecord::Migration
  def change
    drop_table :course_module_element_flash_card_packs
    drop_table :flash_card_stacks
    drop_table :flash_cards
    drop_table :flash_quizzes
    remove_column :course_module_elements, :is_cme_flash_card_pack, :boolean
  end
end
