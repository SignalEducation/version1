class AddSubjectCourseIdToWhitePaperModel < ActiveRecord::Migration
  def change
    add_column :white_papers, :subject_course_id, :integer
  end
end
