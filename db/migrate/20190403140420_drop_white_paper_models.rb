class DropWhitePaperModels < ActiveRecord::Migration[5.2]
  def change
    drop_table :white_paper_requests
    drop_table :white_papers
  end
end
