require 'rails_helper'

RSpec.describe 'UserActivityLogs', type: :request do
  describe 'GET /user_activity_logs' do
    xit 'works! (now write some real specs)' do
      get user_activity_logs_path
      expect(response).to have_http_status(200)
    end
  end
end
