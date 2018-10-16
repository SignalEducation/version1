require 'rails_helper'

RSpec.describe ManagementConsolesController, :type => :controller do

  let(:admin_user_group) { FactoryBot.create(:admin_user_group) }
  let(:admin_user) { FactoryBot.create(:admin_user, user_group_id: admin_user_group.id) }

  context 'Logged in as a admin_user: ' do

    before(:each) do
      activate_authlogic
      UserSession.create!(admin_user)
    end

    describe 'GET index' do
      it 'should redirect to sign_in' do
        get :index
        expect(flash[:success]).to be_nil
        expect(flash[:error]).to be_nil
        expect(response.status).to eq(200)
        expect(response).to render_template(:index)
      end
    end

    describe 'GET system_requirements' do
      it 'should redirect to sign_in' do
        get :system_requirements
        expect(flash[:success]).to be_nil
        expect(flash[:error]).to be_nil
        expect(response.status).to eq(200)
        expect(response).to render_template(:system_requirements)
      end
    end

    describe 'GET public_resources' do
      it 'should redirect to sign_in' do
        get :public_resources
        expect(flash[:success]).to be_nil
        expect(flash[:error]).to be_nil
        expect(response.status).to eq(200)
        expect(response).to render_template(:public_resources)
      end
    end
  end

end