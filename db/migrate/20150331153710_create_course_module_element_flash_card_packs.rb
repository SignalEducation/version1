class CreateCourseModuleElementFlashCardPacks < ActiveRecord::Migration
  def change
    create_table :course_module_element_flash_card_packs do |t|
      t.integer :course_module_element_id
      t.string :background_color
      t.string :foreground_color

      t.timestamps
    end
    add_index :course_module_element_flash_card_packs, :course_module_element_id, name: 'cme_flash_card_pack_cme_id'
  end
end
