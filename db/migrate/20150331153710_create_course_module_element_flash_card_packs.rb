class CreateCourseModuleElementFlashCardPacks < ActiveRecord::Migration
  def change
    create_table :course_module_element_flash_card_packs do |t|
      t.integer :course_module_element_id, index: true
      t.string :background_color
      t.string :foreground_color

      t.timestamps
    end
  end
end
