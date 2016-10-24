class CreateOrders < ActiveRecord::Migration
  def change
    create_table :orders do |t|
      t.integer :product_id, index: true
      t.integer :subject_course_id, index: true
      t.integer :user_id, index: true
      t.string :stripe_guid, index: true
      t.string :stripe_customer_id, index: true
      t.boolean :live_mode, default: false
      t.string :current_status
      t.string :coupon_code

      t.timestamps null: false
    end
  end
end
