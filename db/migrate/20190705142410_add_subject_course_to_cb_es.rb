class AddSubjectCourseToCbEs < ActiveRecord::Migration[5.2]
  def change
    add_reference :cbes, :subject_course, foreign_key: true
  end
end
