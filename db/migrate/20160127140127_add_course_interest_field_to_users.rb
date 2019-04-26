class AddCourseInterestFieldToUsers < ActiveRecord::Migration[4.2]
  def change
    add_column :users, :topic_interest, :string, index: true
  end
end
