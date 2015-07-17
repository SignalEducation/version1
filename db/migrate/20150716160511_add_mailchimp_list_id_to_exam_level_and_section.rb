class AddMailchimpListIdToExamLevelAndSection < ActiveRecord::Migration
  def change
    add_column :exam_levels, :mailchimp_list_id, :string
    add_column :exam_sections, :mailchimp_list_id, :string
  end
end
