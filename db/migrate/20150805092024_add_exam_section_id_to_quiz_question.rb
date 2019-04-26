class AddExamSectionIdToQuizQuestion < ActiveRecord::Migration[4.2]
  def change
    add_column :quiz_questions, :exam_section_id, :integer
  end
end
