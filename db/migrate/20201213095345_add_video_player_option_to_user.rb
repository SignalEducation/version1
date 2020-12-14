class AddVideoPlayerOptionToUser < ActiveRecord::Migration[5.2]
  def change
    add_column :users, :video_player,:integer, default: 0, null: false
  end
end
