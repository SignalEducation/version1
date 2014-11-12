require 'rails_helper'

RSpec.describe "UserNotifications", :type => :request do
  describe "GET /user_notifications" do
    it "works! (now write some real specs)" do
      get user_notifications_path
      expect(response).to have_http_status(200)
    end
  end
end
