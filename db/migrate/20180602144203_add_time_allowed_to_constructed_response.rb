class AddTimeAllowedToConstructedResponse < ActiveRecord::Migration[4.2]
  def change
    add_column :constructed_responses, :time_allowed, :integer
  end
end
