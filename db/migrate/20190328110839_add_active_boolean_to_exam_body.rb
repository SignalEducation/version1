class AddActiveBooleanToExamBody < ActiveRecord::Migration[5.2]
  def change
    add_column :exam_bodies, :active, :boolean, null: false, default: false
    add_column :exam_bodies, :has_sittings, :boolean, null: false, default: false
    remove_column :exam_bodies, :modal_heading, :string
    remove_column :exam_bodies, :modal_text, :text
  end
end
