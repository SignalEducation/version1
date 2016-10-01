class AddFreeTrialBooleanToStudentUserTypes < ActiveRecord::Migration
  def change
    add_column :student_user_types, :free_trial, :boolean, default: false, index: true
  end
end
