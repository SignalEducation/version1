class RenameComplementaryInSubscriptions < ActiveRecord::Migration[4.2]
  def change
    rename_column :subscriptions, :complementary, :complimentary
  end
end
