class AddSortingOrderToWhitePapers < ActiveRecord::Migration[4.2]
  def change
    add_column :white_papers, :sorting_order, :integer
  end
end
