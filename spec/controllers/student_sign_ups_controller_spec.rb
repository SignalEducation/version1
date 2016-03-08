require 'rails_helper'
require 'support/users_and_groups_setup'

RSpec.describe StudentSignUpsController, type: :controller do

  include_context 'users_and_groups_setup'

  before(:each) do
    activate_authlogic
    UserSession.create!(individual_student_user)
  end

  describe "GET 'show'" do
    it 'returns http success' do
      get :show
      expect(response.status).to eq(200)
      expect(response).to render_template(:show)
    end
  end

end
