class CreateCompletionCertificates < ActiveRecord::Migration
  def change
    create_table :completion_certificates do |t|
      t.integer :user_id, index: true
      t.integer :subject_course_user_log_id, index: true
      t.string :guid, index: true

      t.timestamps null: false
    end
  end
end
