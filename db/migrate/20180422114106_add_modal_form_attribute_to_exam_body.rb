class AddModalFormAttributeToExamBody < ActiveRecord::Migration
  def change
    add_column :exam_bodies, :modal_heading, :string
    add_column :exam_bodies, :modal_text, :text
  end
end
