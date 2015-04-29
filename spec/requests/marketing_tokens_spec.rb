require 'rails_helper'

RSpec.describe "MarketingTokens", :type => :request do
  describe "GET /marketing_tokens" do
    it "works! (now write some real specs)" do
      get marketing_tokens_path
      expect(response).to have_http_status(200)
    end
  end
end
