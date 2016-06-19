class AddSortingOrderToWhitePapers < ActiveRecord::Migration
  def change
    add_column :white_papers, :sorting_order, :integer
  end
end
