class AddArchivableAttributesToConstructedResponseModels < ActiveRecord::Migration[4.2]
  def change
    add_column :constructed_responses, :destroyed_at, :datetime
    add_column :scenarios, :destroyed_at, :datetime
    add_column :scenario_questions, :destroyed_at, :datetime
    add_column :scenario_answer_templates, :destroyed_at, :datetime
  end
end
