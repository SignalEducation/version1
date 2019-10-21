class AddExamBodyIdToCoupons < ActiveRecord::Migration[5.2]
  def change
    add_column :coupons, :exam_body_id, :integer
    add_column :coupons, :monthly_interval, :boolean, default: true
    add_column :coupons, :quarterly_interval, :boolean, default: true
    add_column :coupons, :yearly_interval, :boolean, default: true
  end
end
