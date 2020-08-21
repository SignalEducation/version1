class AddVidEndSecondsToCourseSteps < ActiveRecord::Migration[5.2]
  def change
    add_column :course_steps, :vid_end_seconds, :integer
  end
end
