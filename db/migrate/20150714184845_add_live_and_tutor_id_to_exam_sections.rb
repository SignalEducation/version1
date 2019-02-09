class AddLiveAndTutorIdToExamSections < ActiveRecord::Migration[4.2]
  def change
    add_column :exam_sections, :live, :boolean, index: true, default: false, null: false
    add_column :exam_sections, :tutor_id, :integer, index: true
  end
end
