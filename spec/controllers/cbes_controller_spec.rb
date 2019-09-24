require 'rails_helper'

RSpec.describe CbesController, type: :controller do
  let(:sys_group) { create(:system_requirements_user_group) }
  let(:sys_user)  { create(:system_requirements_user, user_group_id: sys_group.id) }
  let(:cbe)       { create(:cbe) }

  before(:each) do
    activate_authlogic
    UserSession.create!(sys_user)
  end

  describe 'GET show' do
    it 'has a 200 status code' do
      get :show, params: { id: cbe.id }

      expect(response.status).to eq(200)
    end
  end
end
