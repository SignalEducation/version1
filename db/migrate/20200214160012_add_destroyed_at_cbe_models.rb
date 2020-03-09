class AddDestroyedAtCbeModels < ActiveRecord::Migration[5.2]
  def change
    add_column :cbe_sections, :destroyed_at, :datetime
    add_column :cbe_sections, :active, :boolean, default: true
    add_column :cbe_scenarios, :destroyed_at, :datetime
    add_column :cbe_scenarios, :active, :boolean, default: true
    add_column :cbe_questions, :destroyed_at, :datetime
    add_column :cbe_questions, :active, :boolean, default: true
  end
end
