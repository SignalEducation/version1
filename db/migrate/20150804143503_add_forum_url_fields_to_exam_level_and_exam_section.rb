class AddForumUrlFieldsToExamLevelAndExamSection < ActiveRecord::Migration[4.2]
  def change
    add_column :exam_levels, :forum_url, :string
    add_column :exam_sections, :forum_url, :string
  end
end
