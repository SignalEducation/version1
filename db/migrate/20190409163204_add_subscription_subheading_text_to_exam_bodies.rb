class AddSubscriptionSubheadingTextToExamBodies < ActiveRecord::Migration[5.2]
  def change
    add_column :exam_bodies, :subscription_page_subheading_text, :string
  end
end
