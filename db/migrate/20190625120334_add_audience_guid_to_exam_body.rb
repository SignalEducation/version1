class AddAudienceGuidToExamBody < ActiveRecord::Migration[5.2]
  def change
    add_column :exam_bodies, :audience_guid, :string
  end
end
