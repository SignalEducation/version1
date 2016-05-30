class AddTranscriptToVideoResource < ActiveRecord::Migration
  def change
    add_column :video_resources, :transcript, :text
  end
end
