class RemoveCompletionCertificateModel < ActiveRecord::Migration[4.2]
  def change
    drop_table :completion_certificates
    drop_table :course_module_jumbo_quizzes
  end
end
