class AddLabelAttributesToSubjectCourseAndCmeModels < ActiveRecord::Migration
  def change
    add_column :subject_courses, :category_label, :string
    add_column :subject_courses, :additional_text_label, :string
    add_column :course_module_elements, :temporary_label, :string
  end
end
