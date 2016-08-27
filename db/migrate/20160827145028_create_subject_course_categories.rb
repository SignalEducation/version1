class CreateSubjectCourseCategories < ActiveRecord::Migration
  def change
    create_table :subject_course_categories do |t|
      t.string :name, index: true
      t.string :payment_type
      t.boolean :active, default: false
      t.string :subdomain, index: true

      t.timestamps null: false
    end
  end
end
