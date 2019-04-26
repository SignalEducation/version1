class AddSubjectCourseIdToWhitePaperModel < ActiveRecord::Migration[4.2]
  def change
    add_column :white_papers, :subject_course_id, :integer
  end
end
