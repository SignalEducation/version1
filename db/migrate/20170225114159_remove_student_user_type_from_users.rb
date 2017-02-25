class RemoveStudentUserTypeFromUsers < ActiveRecord::Migration
  def change
    add_column :users, :free_trial_ended_at, :datetime
    remove_column :users, :student_user_type_id, :integer
  end
end
