require 'rails_helper'

RSpec.describe "QuestionBanks", type: :request do
  describe "GET /question_banks" do
    it "works! (now write some real specs)" do
      get question_banks_path
      expect(response).to have_http_status(200)
    end
  end
end
