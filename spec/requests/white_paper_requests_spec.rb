require 'rails_helper'

RSpec.describe "WhitePaperRequests", type: :request do
  describe "GET /white_paper_requests" do
    it "works! (now write some real specs)" do
      get white_paper_requests_path
      expect(response).to have_http_status(200)
    end
  end
end
