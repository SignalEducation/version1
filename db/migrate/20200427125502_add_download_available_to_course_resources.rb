class AddDownloadAvailableToCourseResources < ActiveRecord::Migration[5.2]
  def change
    add_column :course_notes, :download_available, :boolean, default: false
    add_column :course_resources, :download_available, :boolean, default: false
  end
end
