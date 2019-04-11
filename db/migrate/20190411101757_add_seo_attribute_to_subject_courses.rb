class AddSeoAttributeToSubjectCourses < ActiveRecord::Migration[5.2]
  def change
    add_column :subject_courses, :seo_title, :string
    add_column :subject_courses, :seo_description, :string
  end
end
