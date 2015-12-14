class DropCourseHierarchyTables < ActiveRecord::Migration
  def change
    drop_table :subject_areas
    drop_table :qualifications
    drop_table :institutions
    drop_table :institution_users
    drop_table :exam_levels
    drop_table :exam_sections
  end
end
