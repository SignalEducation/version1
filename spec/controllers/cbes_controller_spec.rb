require 'rails_helper'

RSpec.describe CbesController, type: :controller do
  let(:sys_group) { create(:system_requirements_user_group) }
  let(:sys_user)  { create(:system_requirements_user, user_group_id: sys_group.id) }
  let(:cbe)       { create(:cbe, :with_subject_course) }

  before(:each) do
    activate_authlogic
    UserSession.create!(sys_user)
  end

  describe 'GET show' do
    it 'user has purchased a CBE' do
      expect_any_instance_of(User).to receive('purchased_cbe?').and_return(true)

      get :show, params: { id: cbe.id }
      expect(response.status).to eq(200)
      expect(flash[:error]).to be_nil
    end

    it 'user has not purchased a CBE' do
      get :show, params: { id: cbe.id }

      expect(response.status).to eq(200)
      expect(flash[:error]).to be_present
      expect(flash[:error]).to eq('You need to purchase it before access.')
    end
  end
end
