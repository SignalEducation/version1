class AddActiveToEnrollments < ActiveRecord::Migration
  def change
    add_column :enrollments, :active, :boolean, default: false
    add_column :subject_courses, :email_content, :text
  end
end
