
require 'rails_helper'
require 'support/system_setup'
require 'support/users_and_groups_setup'

RSpec.describe ManagementConsolesController, :type => :controller do

  include_context 'system_setup'
  include_context 'users_and_groups_setup'


  context 'Not logged in: ' do

    describe 'GET index' do
      it 'should redirect to sign_in' do
        get :index
        expect_bounce_as_not_signed_in
      end
    end

    describe 'GET system_requirements' do
      it 'should redirect to sign_in' do
        get :system_requirements
        expect_bounce_as_not_signed_in
      end
    end
  end

  context 'Logged in as a valid_trial_student: ' do

    before(:each) do
      activate_authlogic
      UserSession.create!(valid_trial_student)
    end

    describe 'GET index' do
      it 'should redirect to sign_in' do
        get :index
        expect_bounce_as_not_allowed
      end
    end

    describe 'GET system_requirements' do
      it 'should redirect to sign_in' do
        get :system_requirements
        expect_bounce_as_not_allowed
      end
    end
  end

  context 'Logged in as a invalid_trial_student: ' do

    before(:each) do
      activate_authlogic
      UserSession.create!(invalid_trial_student)
    end

    describe 'GET index' do
      it 'should redirect to sign_in' do
        get :index
        expect_bounce_as_not_allowed
      end
    end

    describe 'GET system_requirements' do
      it 'should redirect to sign_in' do
        get :system_requirements
        expect_bounce_as_not_allowed
      end
    end
  end

  context 'Logged in as a valid_subscription_student: ' do

    before(:each) do
      activate_authlogic
      UserSession.create!(valid_subscription_student)
    end

    describe 'GET index' do
      it 'should redirect to sign_in' do
        get :index
        expect_bounce_as_not_allowed
      end
    end

    describe 'GET system_requirements' do
      it 'should redirect to sign_in' do
        get :system_requirements
        expect_bounce_as_not_allowed
      end
    end
  end

  context 'Logged in as a invalid_subscription_student: ' do

    before(:each) do
      activate_authlogic
      UserSession.create!(invalid_subscription_student)
    end

    describe 'GET index' do
      it 'should redirect to sign_in' do
        get :index
        expect_bounce_as_not_allowed
      end
    end

    describe 'GET system_requirements' do
      it 'should redirect to sign_in' do
        get :system_requirements
        expect_bounce_as_not_allowed
      end
    end
  end

  context 'Logged in as a comp_user: ' do

    before(:each) do
      activate_authlogic
      UserSession.create!(comp_user)
    end

    describe 'GET index' do
      it 'should redirect to sign_in' do
        get :index
        expect_bounce_as_not_allowed
      end
    end

    describe 'GET system_requirements' do
      it 'should redirect to sign_in' do
        get :system_requirements
        expect_bounce_as_not_allowed
      end
    end
  end

  context 'Logged in as a tutor_user: ' do

    before(:each) do
      activate_authlogic
      UserSession.create!(tutor_user)
    end

    describe 'GET index' do
      #TODO allow tutor users navigate to this page
      #TODO and have it display general stats on their courses
      xit 'should redirect to sign_in' do
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
        expect_bounce_as_not_allowed
      end
    end
  end

  context 'Logged in as a content_manager_user: ' do

    before(:each) do
      activate_authlogic
      UserSession.create!(content_manager_user)
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
        expect_bounce_as_not_allowed
      end
    end
  end

  context 'Logged in as a marketing_manager_user: ' do

    before(:each) do
      activate_authlogic
      UserSession.create!(marketing_manager_user)
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
  end

  context 'Logged in as a customer_support_manager_user: ' do

    before(:each) do
      activate_authlogic
      UserSession.create!(customer_support_manager_user)
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
        expect_bounce_as_not_allowed
      end
    end
  end

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
  end

end