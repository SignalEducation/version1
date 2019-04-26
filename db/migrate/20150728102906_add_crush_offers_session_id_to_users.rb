class AddCrushOffersSessionIdToUsers < ActiveRecord::Migration[4.2]
  def change
    add_column :users, :crush_offers_session_id, :string
  end
end
