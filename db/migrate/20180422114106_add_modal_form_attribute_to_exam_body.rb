class AddModalFormAttributeToExamBody < ActiveRecord::Migration[4.2]
  def change
    add_column :exam_bodies, :modal_heading, :string
    add_column :exam_bodies, :modal_text, :text
  end
end
