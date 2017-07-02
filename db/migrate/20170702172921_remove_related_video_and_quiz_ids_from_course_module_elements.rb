class RemoveRelatedVideoAndQuizIdsFromCourseModuleElements < ActiveRecord::Migration
  def change
    remove_column :course_module_elements, :related_quiz_id, :integer
    remove_column :course_module_elements, :related_video_id, :integer
  end
end
