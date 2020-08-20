class ChangeContentToTextCbeRequirement < ActiveRecord::Migration[5.2]
  def change
    change_column :cbe_requirements, :content, :text
  end
end
