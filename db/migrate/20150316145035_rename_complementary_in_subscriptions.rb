class RenameComplementaryInSubscriptions < ActiveRecord::Migration
  def change
    rename_column :subscriptions, :complementary, :complimentary
  end
end
