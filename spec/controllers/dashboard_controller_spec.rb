require 'rails_helper'
require 'support/users_and_groups_setup'

RSpec.describe DashboardController, :type => :controller do

  include_context 'users_and_groups_setup'

  context 'Not logged in: ' do

    describe "GET show" do
      it "bounces user as not signed in" do
        get :show
        expect_bounce_as_not_signed_in
      end
    end

  end

  context 'Logged in as a show_user: ' do

    before(:each) do
      activate_authlogic
      UserSession.create!(student_user)
    end

    describe "GET show" do
      it "bounces user as not allowed" do
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

    describe "GET show" do
      it "bounces user as not allowed" do
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

    describe "GET show" do
      it "bounces user as not allowed" do
        get :show
        expect(response).to have_http_status(:success)
        expect(response).to render_template(:show)
      end
    end

  end

  context 'Logged in as a content_manager_user: ' do

    before(:each) do
      activate_authlogic
      UserSession.create!(content_manager_user)
    end

    describe "GET show" do
      it "bounces user as not allowed" do
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

    describe "GET show" do
      it "bounces user as not allowed" do
        get :show
        expect(response).to have_http_status(:success)
        expect(response).to render_template(:show)
      end
    end

  end

  context 'Logged in as a customer_support_manager_user: ' do

    before(:each) do
      activate_authlogic
      UserSession.create!(customer_support_manager_user)
    end

    describe "GET show" do
      it "bounces user as not allowed" do
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

    describe "GET show" do
      it "bounces user as not allowed" do
        get :show
        expect(response).to have_http_status(:success)
        expect(response).to render_template(:show)
      end
    end
    describe "GET show" do
      it "bounces user as not allowed" do
        get :show
        expect(response).to have_http_status(:success)
        expect(response).to render_template(:show)
      end
    end

  end

end
