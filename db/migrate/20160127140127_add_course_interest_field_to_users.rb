class AddCourseInterestFieldToUsers < ActiveRecord::Migration
  def change
    add_column :users, :topic_interest, :string, index: true
  end
end
