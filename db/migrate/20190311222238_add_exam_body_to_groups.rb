class AddExamBodyToGroups < ActiveRecord::Migration[5.2]
  def change
    add_reference :groups, :exam_body, foreign_key: true
  end
end
