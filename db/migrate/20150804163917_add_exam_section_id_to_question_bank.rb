class AddExamSectionIdToQuestionBank < ActiveRecord::Migration
  def change
    add_column :question_banks, :exam_section_id, :integer, index: true
  end
end
