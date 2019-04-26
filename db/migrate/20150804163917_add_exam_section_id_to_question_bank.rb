class AddExamSectionIdToQuestionBank < ActiveRecord::Migration[4.2]
  def change
    add_column :question_banks, :exam_section_id, :integer, index: true
  end
end
