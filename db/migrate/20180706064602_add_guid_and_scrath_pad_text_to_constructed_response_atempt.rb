class AddGuidAndScrathPadTextToConstructedResponseAtempt < ActiveRecord::Migration[4.2]
  def change
    add_column :constructed_response_attempts, :guid, :string
    add_column :constructed_response_attempts, :scratch_pad_text, :text
  end
end
