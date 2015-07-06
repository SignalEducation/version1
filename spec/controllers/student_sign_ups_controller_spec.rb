require 'rails_helper'

RSpec.describe StudentSignUpsController, type: :controller do

  describe "GET 'show'" do
    it 'returns http success' do
      get :show
      expect(response.status).to eq(200)
      expect(response).to render_template(:show)
    end
  end

end
