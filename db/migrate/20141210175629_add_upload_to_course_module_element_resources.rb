class AddUploadToCourseModuleElementResources < ActiveRecord::Migration[4.2]
  def up
    add_attachment :course_module_element_resources, :upload
  end

  def down
    remove_attachment :course_module_element_resources, :upload
  end
end
