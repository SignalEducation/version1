class AddCbeIdToProducts < ActiveRecord::Migration[5.2]
  def change
    add_reference :products, :cbe, index: true
  end
end
