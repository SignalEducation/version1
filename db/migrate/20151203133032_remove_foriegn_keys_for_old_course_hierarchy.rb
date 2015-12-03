class RemoveForiegnKeysForOldCourseHierarchy < ActiveRecord::Migration
  def change
    remove_column :course_modules, :exam_level_id, :integer
    remove_column :course_modules, :exam_section_id, :integer
    remove_column :course_modules, :qualification_id, :integer
    remove_column :course_modules, :institution_id, :integer
    remove_column :quiz_questions, :exam_level_id, :integer
    remove_column :quiz_questions, :exam_section_id, :integer
    remove_column :corporate_group_grants, :exam_level_id, :integer
    remove_column :corporate_group_grants, :exam_section_id, :integer
    remove_column :student_exam_tracks, :exam_level_id, :integer
    remove_column :student_exam_tracks, :exam_section_id, :integer
  end
end
