class AddKindToCbeIntroductionPages < ActiveRecord::Migration[5.2]
  def change
    add_column :cbe_introduction_pages, :kind, :integer, default: 0, null: false
  end
end
