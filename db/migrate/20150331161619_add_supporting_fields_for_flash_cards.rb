class AddSupportingFieldsForFlashCards < ActiveRecord::Migration

  def change
    add_column :quiz_contents, :flash_card_id, :integer, index: true
    add_column :quiz_questions, :flash_quiz_id, :integer, index: true
    add_column :course_module_elements, :is_cme_flash_card_pack, :boolean, default: false, null: false, index: true
  end

end