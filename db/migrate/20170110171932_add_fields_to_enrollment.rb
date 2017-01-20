class AddFieldsToEnrollment < ActiveRecord::Migration
  def change
    add_column :enrollments, :student_number, :string, index: :true
    add_column :enrollments, :exam_body_id, :integer, index: :true
    add_column :enrollments, :exam_date, :date
    add_column :enrollments, :registered, :boolean, default: :false
  end

end
