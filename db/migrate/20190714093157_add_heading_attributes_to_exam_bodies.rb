class AddHeadingAttributesToExamBodies < ActiveRecord::Migration[5.2]
  def change
    add_column :exam_bodies, :landing_page_h1, :string
    add_column :exam_bodies, :landing_page_paragraph, :text
  end
end
