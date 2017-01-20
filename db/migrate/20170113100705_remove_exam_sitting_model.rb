class RemoveExamSittingModel < ActiveRecord::Migration
  def change
    drop_table :user_exam_sittings
  end
end
