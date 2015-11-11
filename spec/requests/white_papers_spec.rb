require 'rails_helper'

RSpec.describe "WhitePapers", type: :request do
  describe "GET /white_papers" do
    it "works! (now write some real specs)" do
      get white_papers_path
      expect(response).to have_http_status(200)
    end
  end
end
