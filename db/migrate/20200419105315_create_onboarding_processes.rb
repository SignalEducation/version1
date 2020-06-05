class CreateOnboardingProcesses < ActiveRecord::Migration[5.2]
  def change
    create_table :onboarding_processes do |t|
      t.integer :user_id, index: true
      t.integer :student_exam_track_id, index: true
      t.boolean :active, default: true, null: false

      t.timestamps
    end
  end
end
