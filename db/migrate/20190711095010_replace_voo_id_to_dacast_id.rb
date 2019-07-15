class ReplaceVooIdToDacastId < ActiveRecord::Migration[5.2]
  def change
    rename_column :course_module_element_videos, :voo_player_id, :dacast_id
  end
end
