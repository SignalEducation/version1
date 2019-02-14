class AddTranscriptToVideoResource < ActiveRecord::Migration[4.2]
  def change
    add_column :video_resources, :transcript, :text
  end
end
