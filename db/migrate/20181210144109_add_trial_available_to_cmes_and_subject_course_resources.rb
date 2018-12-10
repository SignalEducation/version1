class AddTrialAvailableToCmesAndSubjectCourseResources < ActiveRecord::Migration
  def change
    add_column :course_module_elements, :available_on_trial, :boolean, default: false
    add_column :subject_course_resources, :available_on_trial, :boolean, default: false
  end
end
