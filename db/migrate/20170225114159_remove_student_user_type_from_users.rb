class RemoveStudentUserTypeFromUsers < ActiveRecord::Migration[4.2]
  def change
    add_column :users, :free_trial_ended_at, :datetime
    remove_column :users, :student_user_type_id, :integer
  end
end
