class RemoveActiveFieldCbeIntroductionPage < ActiveRecord::Migration[5.2]
  def change
    remove_column :cbe_introduction_pages, :active, :boolean
  end
end
