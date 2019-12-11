class AddExamBodyIdToExternalBanners < ActiveRecord::Migration[5.2]
  def change
    add_column :external_banners, :exam_body_id, :integer
  end
end
