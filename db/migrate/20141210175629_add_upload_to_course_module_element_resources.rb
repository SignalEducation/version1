class AddUploadToCourseModuleElementResources < ActiveRecord::Migration
  def up
    add_attachment :course_module_element_resources, :upload
  end

  def down
    remove_attachment :course_module_element_resources, :upload
  end
end
