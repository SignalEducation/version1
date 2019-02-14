class AddSubjectCourseIdToContentPageSections < ActiveRecord::Migration[4.2]
  def change
    add_column :content_page_sections, :subject_course_id, :integer
    add_column :content_page_sections, :sorting_order, :integer
  end
end
