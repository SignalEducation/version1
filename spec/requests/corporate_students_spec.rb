require 'rails_helper'

RSpec.describe "CorporateStudents", type: :request do
  describe "GET /corporate_students" do
    it "works! (now write some real specs)" do
      get corporate_students_path
      expect(response).to have_http_status(200)
    end
  end
end
