class CreateExamBodyUserDetails < ActiveRecord::Migration[4.2]
  def change
    create_table :exam_body_user_details do |t|
      t.integer :user_id, index: true
      t.integer :exam_body_id, index: true
      t.string :student_number

      t.timestamps null: false
    end

    acca_exam_body = ExamBody.where(name: 'ACCA').first
    if acca_exam_body
      User.where.not(student_number: '').each do |user|
        ExamBodyUserDetail.create(user_id: user.id, exam_body_id: acca_exam_body.id, student_number: user.student_number)
      end
    end

  end
end
