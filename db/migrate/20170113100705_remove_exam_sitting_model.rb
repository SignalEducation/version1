class RemoveExamSittingModel < ActiveRecord::Migration[4.2]
  def change
    drop_table :user_exam_sittings
  end
end
