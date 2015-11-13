class CreateWhitePaperRequests < ActiveRecord::Migration
  def change
    create_table :white_paper_requests do |t|
      t.string :name, index: true
      t.string :email, index: true
      t.string :number, index: true
      t.string :web_url
      t.string :company_name, index: true
      t.integer :white_paper_id, index: true

      t.timestamps null: false
    end
  end
end
