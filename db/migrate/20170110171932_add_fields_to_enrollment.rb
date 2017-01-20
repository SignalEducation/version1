class AddFieldsToEnrollment < ActiveRecord::Migration
  def change
    add_column :enrollments, :student_number, :string, index: :true
    add_column :enrollments, :exam_body_id, :integer, index: :true
    add_column :enrollments, :exam_date, :date
    add_column :enrollments, :registered, :boolean, default: :false
  end

  unless Rails.env.test?
    users = User.where.not(student_number: nil).where.not(student_number: '')
    users.each do |user|
      user.enrollments.each do |enrollment|
        enrollment.update_attribute(:student_number, user.student_number) if user.student_number
      end
    end
  end

end
