class AddVimeoGuidToCourseModuleElementVideo < ActiveRecord::Migration
  def change
    add_column :course_module_element_videos, :vimeo_guid, :string, index: true
  end
end
