class AddHasCorrectionPacksToSubjectCourse < ActiveRecord::Migration[5.2]
  def change
    add_column :subject_courses, :has_correction_packs, :boolean, default: false
  end
end
