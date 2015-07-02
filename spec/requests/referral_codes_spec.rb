require 'rails_helper'

RSpec.describe "ReferralCodes", type: :request do
  describe "GET /referral_codes" do
    it "works! (now write some real specs)" do
      get referral_codes_path
      expect(response).to have_http_status(302)
    end
  end
end
