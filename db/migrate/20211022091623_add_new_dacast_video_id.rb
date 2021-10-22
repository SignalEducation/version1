class AddNewDacastVideoId < ActiveRecord::Migration[5.2]
  def change
    add_column :course_videos, :new_dacast_id, :string
  end
end
