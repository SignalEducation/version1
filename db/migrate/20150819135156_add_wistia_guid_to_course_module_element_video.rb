class AddWistiaGuidToCourseModuleElementVideo < ActiveRecord::Migration[4.2]
  def change
    add_column :course_module_element_videos, :video_id, :string, index: true
  end
end
