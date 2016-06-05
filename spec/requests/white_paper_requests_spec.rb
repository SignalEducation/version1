# == Schema Information
#
# Table name: white_paper_requests
#
#  id             :integer          not null, primary key
#  name           :string
#  email          :string
#  number         :string
#  company_name   :string
#  white_paper_id :integer
#  created_at     :datetime         not null
#  updated_at     :datetime         not null
#

require 'rails_helper'

RSpec.describe "WhitePaperRequests", type: :request do
  describe "GET /white_paper_requests" do
    it "works! (now write some real specs)" do
      get white_paper_requests_path
      expect(response).to have_http_status(200)
    end
  end
end
