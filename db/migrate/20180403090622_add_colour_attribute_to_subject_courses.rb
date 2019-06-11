class AddColourAttributeToSubjectCourses < ActiveRecord::Migration[4.2]
  def change
    add_column :subject_courses, :highlight_colour, :string, default: '#ef475d'
  end
end
