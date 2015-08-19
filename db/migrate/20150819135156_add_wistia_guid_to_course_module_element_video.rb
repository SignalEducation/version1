class AddWistiaGuidToCourseModuleElementVideo < ActiveRecord::Migration
  def change
    add_column :course_module_element_videos, :video_id, :string, index: true
  end
end
