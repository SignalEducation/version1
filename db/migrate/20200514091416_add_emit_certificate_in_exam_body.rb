class AddEmitCertificateInExamBody < ActiveRecord::Migration[5.2]
  def change
    add_column :exam_bodies, :emit_certificate, :boolean, default: false
  end
end
