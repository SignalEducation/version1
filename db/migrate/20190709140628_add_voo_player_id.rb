class AddVooPlayerId < ActiveRecord::Migration[5.2]
  def change
    add_column :course_module_element_videos, :voo_player_id, :string
  end
end
