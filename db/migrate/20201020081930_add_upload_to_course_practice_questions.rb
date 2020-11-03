class AddUploadToCoursePracticeQuestions < ActiveRecord::Migration[5.2]
  def change
    add_attachment :course_practice_questions, :document
  end
end
