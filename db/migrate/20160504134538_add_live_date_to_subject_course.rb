class AddLiveDateToSubjectCourse < ActiveRecord::Migration[4.2]
  def change
    add_column :subject_courses, :live_date, :datetime, index: true, default: nil
  end
end
