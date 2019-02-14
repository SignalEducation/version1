class RemoveCorproateRequestsAndTutorApplicationsTables < ActiveRecord::Migration[4.2]
  def change
    drop_table :corporate_requests
    drop_table :tutor_applications
  end
end
