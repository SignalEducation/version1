class AddAccredibleGroupIdInCourse < ActiveRecord::Migration[5.2]
  def change
    add_column :courses, :accredible_group_id, :integer
  end
end
