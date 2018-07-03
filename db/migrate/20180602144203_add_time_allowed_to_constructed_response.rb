class AddTimeAllowedToConstructedResponse < ActiveRecord::Migration
  def change
    add_column :constructed_responses, :time_allowed, :integer
  end
end
