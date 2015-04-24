class MakeFlashCardsStuffArchivable < ActiveRecord::Migration
  def change
    add_column :course_module_element_flash_card_packs, :destroyed_at, :datetime, index: true
    add_column :flash_card_stacks, :destroyed_at, :datetime, index: true
    add_column :flash_cards, :destroyed_at, :datetime, index: true
    add_column :flash_quizzes, :destroyed_at, :datetime, index: true
  end
end
