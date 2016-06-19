class AddNameUrlToWhitePapers < ActiveRecord::Migration
  def change
    add_column :white_papers, :name_url, :string
    remove_column :white_paper_requests, :web_url, :string
  end
end
