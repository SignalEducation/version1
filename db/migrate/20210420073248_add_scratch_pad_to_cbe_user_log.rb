class AddScratchPadToCbeUserLog < ActiveRecord::Migration[5.2]
  def change
    add_column :cbe_user_logs, :scratch_pad, :text
  end
end
