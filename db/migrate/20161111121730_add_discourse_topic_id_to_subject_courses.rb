class AddDiscourseTopicIdToSubjectCourses < ActiveRecord::Migration
  def change
    add_column :subject_courses, :discourse_topic_id, :integer, index: true
    remove_column :subject_courses, :forum_url, :string
  end
end
