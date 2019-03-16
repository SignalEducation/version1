class AddFreeTrialBooleanToStudentUserTypes < ActiveRecord::Migration[4.2]
  def change
    add_column :student_user_types, :free_trial, :boolean, default: false, index: true

  end
end
