require 'rails_helper'
require 'support/users_and_groups_setup'

RSpec.describe DashboardController, :type => :controller do

  include_context 'users_and_groups_setup'

  context 'Not logged in: ' do

    describe 'GET show' do
      it 'should bounce as not signed in' do
        get :show
        expect_bounce_as_not_signed_in
      end
    end

  end

  context 'Logged in as a valid_trial student_user: ' do

    before(:each) do
      activate_authlogic
      UserSession.create!(valid_trial_student)
    end

    describe 'GET show' do
      it 'should respond OK' do
        get :show
        expect(response).to have_http_status(:success)
        expect(response).to render_template(:show)
      end
    end

  end

  context 'Logged in as a invalid_trial student_user: ' do

    before(:each) do
      activate_authlogic
      UserSession.create!(invalid_trial_student)
    end

    describe 'GET show' do
      it 'should respond OK' do
        get :show
        expect(response).to have_http_status(:success)
        expect(response).to render_template(:show)
      end
    end

  end

  context 'Logged in as a valid_subscription_student: ' do

    before(:each) do
      activate_authlogic
      UserSession.create!(valid_subscription_student)
    end

    describe 'GET show' do
      it 'should respond OK' do
        get :show
        expect(response).to have_http_status(:success)
        expect(response).to render_template(:show)
      end
    end

  end

  context 'Logged in as a invalid_subscription_student: ' do

    before(:each) do
      activate_authlogic
      UserSession.create!(invalid_subscription_student)
    end

    describe 'GET show' do
      it 'should respond OK' do
        get :show
        expect(response).to have_http_status(:success)
        expect(response).to render_template(:show)
      end
    end

  end

  context 'Logged in as a complimentary_user: ' do

    before(:each) do
      activate_authlogic
      UserSession.create!(comp_user)
    end

    describe 'GET show' do
      it 'should respond OK' do
        get :show
        expect(response).to have_http_status(:success)
        expect(response).to render_template(:show)
      end
    end

  end

  context 'Logged in as a tutor_user: ' do

    before(:each) do
      activate_authlogic
      UserSession.create!(tutor_user)
    end

    describe 'GET show' do
      it 'should respond OK' do
        get :show
        expect(response).to have_http_status(:success)
        expect(response).to render_template(:show)
      end
    end

  end

  context 'Logged in as a system_requirements_user: ' do

    before(:each) do
      activate_authlogic
      UserSession.create!(system_requirements_user)
    end

    describe 'GET show' do
      it 'should respond OK' do
        get :show
        expect(response).to have_http_status(:success)
        expect(response).to render_template(:show)
      end
    end


  end

  context 'Logged in as a content_management_user: ' do

    before(:each) do
      activate_authlogic
      UserSession.create!(content_management_user)
    end

    describe 'GET show' do
      it 'should respond OK' do
        get :show
        expect(response).to have_http_status(:success)
        expect(response).to render_template(:show)
      end
    end


  end

  context 'Logged in as a stripe_management_user: ' do

    before(:each) do
      activate_authlogic
      UserSession.create!(stripe_management_user)
    end

    describe 'GET show' do
      it 'should respond OK' do
        get :show
        expect(response).to have_http_status(:success)
        expect(response).to render_template(:show)
      end
    end


  end

  context 'Logged in as a user_management_user: ' do

    before(:each) do
      activate_authlogic
      UserSession.create!(user_management_user)
    end

    describe 'GET show' do
      it 'should respond OK' do
        get :show
        expect(response).to have_http_status(:success)
        expect(response).to render_template(:show)
      end
    end


  end

  context 'Logged in as a developers_user: ' do

    before(:each) do
      activate_authlogic
      UserSession.create!(developers_user)
    end

    describe 'GET show' do
      it 'should respond OK' do
        get :show
        expect(response).to have_http_status(:success)
        expect(response).to render_template(:show)
      end
    end


  end

  context 'Logged in as a marketing_manager_user: ' do

    before(:each) do
      activate_authlogic
      UserSession.create!(marketing_manager_user)
    end

    describe 'GET show' do
      it 'should respond OK' do
        get :show
        expect(response).to have_http_status(:success)
        expect(response).to render_template(:show)
      end
    end

  end

  context 'Logged in as a user_group_manager_user: ' do

    before(:each) do
      activate_authlogic
      UserSession.create!(user_group_manager_user)
    end

    describe 'GET show' do
      it 'should respond OK' do
        get :show
        expect(response).to have_http_status(:success)
        expect(response).to render_template(:show)
      end
    end

  end

  context 'Logged in as a admin_user: ' do

    before(:each) do
      activate_authlogic
      UserSession.create!(admin_user)
    end

    describe 'GET show' do
      it 'should respond OK' do
        get :show
        expect(response).to have_http_status(:success)
        expect(response).to render_template(:show)
      end
    end

  end

end
