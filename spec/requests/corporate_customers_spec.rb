require 'rails_helper'

RSpec.describe 'CorporateCustomers', type: :request do
  describe 'GET /corporate_customers' do
    xit 'works! (now write some real specs)' do
      get corporate_customers_path
      expect(response).to have_http_status(200)
    end
  end
end
