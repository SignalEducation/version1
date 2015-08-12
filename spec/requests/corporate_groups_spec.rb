require 'rails_helper'

RSpec.describe "CorporateGroups", type: :request do
  describe "GET /corporate_groups" do
    it "works! (now write some real specs)" do
      get corporate_groups_path
      expect(response).to have_http_status(200)
    end
  end
end
