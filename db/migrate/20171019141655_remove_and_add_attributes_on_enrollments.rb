class RemoveAndAddAttributesOnEnrollments < ActiveRecord::Migration[4.2]
  def change
    remove_column :enrollments, :student_number, :string
    remove_column :enrollments, :registered, :boolean, default: false

    add_column :enrollments, :expired, :boolean, default: false
    add_column :enrollments, :paused, :boolean, default: false
    add_column :enrollments, :notifications, :boolean, default: true
  end
end
