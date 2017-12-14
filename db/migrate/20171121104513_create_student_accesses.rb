class CreateStudentAccesses < ActiveRecord::Migration
  def change
    create_table :student_accesses do |t|
      t.integer :user_id
      t.datetime :trial_started_date
      t.datetime :trial_ending_at_date
      t.datetime :trial_ended_date
      t.integer :trial_seconds_limit, index: true
      t.integer :trial_days_limit, index: true
      t.integer :content_seconds_consumed, index: true, default: 0
      t.integer :subscription_id, index: true
      t.string :account_type, index: true
      t.boolean :content_access, default: false, index: true

      t.timestamps null: false
    end
  end
end
