require 'rails_helper'
require 'support/users_and_groups_setup'

RSpec.describe StudentSignUpsController, type: :controller do

  include_context 'users_and_groups_setup'

  let!(:unverified_user) { FactoryGirl.create(:individual_student_user, account_activated_at: nil, account_activation_code: '987654321', active: false, email_verified_at: nil, email_verification_code: '123456687', email_verified: false) }


  describe "GET 'show'" do
    it 'returns http success' do
      get :show, account_activation_code: unverified_user.account_activation_code
      expect(response.status).to eq(200)
      expect(response).to render_template(:show)
    end
  end

  describe "GET 'account_verified'" do

    before(:each) do
      activate_authlogic
      UserSession.create!(individual_student_user)
    end

    it 'returns http success' do
      get :account_verified
      expect(response.status).to eq(200)
      expect(response).to render_template(:account_verified)
    end
  end

end
