class AddStatsContentToHomePages < ActiveRecord::Migration[5.2]
  def change
    add_column :home_pages, :stats_content, :text
  end
end
