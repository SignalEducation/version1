class AddSubjectCourseToQuizQuestion < ActiveRecord::Migration
  def change
    add_column :quiz_questions, :subject_course_id, :integer, index: true
  end
end
