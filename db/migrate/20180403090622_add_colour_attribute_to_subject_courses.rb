class AddColourAttributeToSubjectCourses < ActiveRecord::Migration
  def change
    add_column :subject_courses, :highlight_colour, :string, default: '#ef475d'
  end
end
