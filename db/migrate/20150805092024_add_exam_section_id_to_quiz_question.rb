class AddExamSectionIdToQuizQuestion < ActiveRecord::Migration
  def change
    add_column :quiz_questions, :exam_section_id, :integer
  end
end
