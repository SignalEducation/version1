class ChangeWhitePaperTitleToName < ActiveRecord::Migration[4.2]
  def change
    add_column :white_papers, :name, :string
    remove_column :white_papers, :title, :string
  end
end
