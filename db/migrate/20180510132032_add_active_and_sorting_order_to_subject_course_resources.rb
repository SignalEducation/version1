class AddActiveAndSortingOrderToSubjectCourseResources < ActiveRecord::Migration[4.2]
  def change
    add_column :subject_course_resources, :active, :boolean, default: false, index: true
    add_column :subject_course_resources, :sorting_order, :integer
  end
end
