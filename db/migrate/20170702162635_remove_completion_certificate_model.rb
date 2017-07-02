class RemoveCompletionCertificateModel < ActiveRecord::Migration
  def change
    drop_table :completion_certificates
    drop_table :course_module_jumbo_quizzes
  end
end
