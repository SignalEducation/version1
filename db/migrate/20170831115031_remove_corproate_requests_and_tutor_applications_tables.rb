class RemoveCorproateRequestsAndTutorApplicationsTables < ActiveRecord::Migration
  def change
    drop_table :corporate_requests
    drop_table :tutor_applications
  end
end
