class AddActiveAndSortingOrderToSubjectCourseResources < ActiveRecord::Migration
  def change
    add_column :subject_course_resources, :active, :boolean, default: false, index: true
    add_column :subject_course_resources, :sorting_order, :integer
  end
end
