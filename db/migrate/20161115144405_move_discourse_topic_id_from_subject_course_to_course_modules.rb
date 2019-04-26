class MoveDiscourseTopicIdFromSubjectCourseToCourseModules < ActiveRecord::Migration[4.2]
  def change
    add_column :course_modules, :discourse_topic_id, :integer
    remove_column :subject_courses, :discourse_topic_id, :integer
  end
end
