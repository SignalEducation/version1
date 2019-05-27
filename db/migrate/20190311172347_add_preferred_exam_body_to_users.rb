class AddPreferredExamBodyToUsers < ActiveRecord::Migration[5.2]
  def change
    add_reference :users, :preferred_exam_body, foreign_key: { to_table: :exam_bodies }
  end
end
