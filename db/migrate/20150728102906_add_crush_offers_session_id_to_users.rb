class AddCrushOffersSessionIdToUsers < ActiveRecord::Migration
  def change
    add_column :users, :crush_offers_session_id, :string
  end
end
