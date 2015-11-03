class AddDestroyedAtToSubjectCoursesAndGroups < ActiveRecord::Migration
  def change
    add_column :groups, :destroyed_at, :datetime, index: true
    add_column :subject_courses, :destroyed_at, :datetime, index: true
  end
end
