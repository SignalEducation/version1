class AddFaqsToProduct < ActiveRecord::Migration[5.2]
  def change
    add_column :faqs, :product_id, :integer
  end
end
