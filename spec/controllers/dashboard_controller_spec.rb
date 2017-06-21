require 'rails_helper'
require 'support/users_and_groups_setup'

RSpec.describe DashboardController, :type => :controller do

  include_context 'users_and_groups_setup'

  context 'Not logged in: ' do

    describe "GET admin" do
      it "bounces user as not signed in" do
        get :admin
        expect_bounce_as_not_signed_in
      end
    end

    describe "GET export_users" do
      it "bounces user as not signed in" do
        get :export_users
        expect_bounce_as_not_signed_in
      end
    end

    describe "GET export_users_monthly" do
      it "bounces user as not signed in" do
        get :export_users_monthly
        expect_bounce_as_not_signed_in
      end
    end

    describe "GET export_courses" do
      it "bounces user as not allowed" do
        get :export_courses
        expect_bounce_as_not_signed_in
      end
    end

    describe "GET content_manager" do
      it "bounces user as not signed in" do
        get :content_manager
        expect_bounce_as_not_signed_in
      end
    end

    describe "GET marketing_manager" do
      it "bounces user as not signed in" do
        get :marketing_manager
        expect_bounce_as_not_signed_in
      end
    end

    describe "GET customer_support_manager" do
      it "bounces user as not signed in" do
        get :customer_support_manager
        expect_bounce_as_not_signed_in
      end
    end

    describe "GET student" do
      it "bounces user as not signed in" do
        get :student
        expect_bounce_as_not_signed_in
      end
    end

    describe "GET tutor" do
      it "bounces user as not signed in" do
        get :tutor
        expect_bounce_as_not_signed_in
      end
    end

  end

  context 'Logged in as a individual_student_user: ' do

    before(:each) do
      activate_authlogic
      UserSession.create!(individual_student_user)
    end

    describe "GET admin" do
      it "bounces user as not allowed" do
        get :admin
        expect_bounce_as_not_allowed
      end
    end

    describe "GET export_users" do
      it "bounces user as not allowed" do
        get :export_users
        expect_bounce_as_not_allowed
      end
    end

    describe "GET export_users_monthly" do
      it "bounces user as not allowed" do
        get :export_users_monthly
        expect_bounce_as_not_allowed
      end
    end

    describe "GET export_courses" do
      it "bounces user as not allowed" do
        get :export_courses
        expect_bounce_as_not_allowed
      end
    end

    describe "GET content_manager" do
      it "bounces user as not allowed" do
        get :content_manager
        expect_bounce_as_not_allowed
      end
    end

    describe "GET marketing_manager" do
      it "bounces user as not allowed" do
        get :marketing_manager
        expect_bounce_as_not_allowed
      end
    end

    describe "GET customer_support_manager" do
      it "bounces user as not allowed" do
        get :customer_support_manager
        expect_bounce_as_not_allowed
      end
    end

    describe "GET student" do
      it "return http success" do
        get :student
        expect(response).to have_http_status(:success)
        expect(response).to render_template(:student)
      end
    end

    describe "GET tutor" do
      it "bounces user as not allowed" do
        get :tutor
        expect_bounce_as_not_allowed
      end
    end

  end

  context 'Logged in as a complimentary_user: ' do

    before(:each) do
      activate_authlogic
      UserSession.create!(comp_user)
    end

    describe "GET admin" do
      it "bounces user as not allowed" do
        get :admin
        expect_bounce_as_not_allowed
      end
    end

    describe "GET export_users" do
      it "bounces user as not allowed" do
        get :export_users
        expect_bounce_as_not_allowed
      end
    end

    describe "GET export_users_monthly" do
      it "bounces user as not allowed" do
        get :export_users_monthly
        expect_bounce_as_not_allowed
      end
    end

    describe "GET export_courses" do
      it "bounces user as not allowed" do
        get :export_courses
        expect_bounce_as_not_allowed
      end
    end

    describe "GET content_manager" do
      it "bounces user as not allowed" do
        get :content_manager
        expect_bounce_as_not_allowed
      end
    end

    describe "GET marketing_manager" do
      it "bounces user as not allowed" do
        get :marketing_manager
        expect_bounce_as_not_allowed
      end
    end

    describe "GET customer_support_manager" do
      it "bounces user as not allowed" do
        get :customer_support_manager
        expect_bounce_as_not_allowed
      end
    end

    describe "GET student" do
      it "return http success" do
        get :student
        expect(response).to have_http_status(:success)
        expect(response).to render_template(:student)
      end
    end

    describe "GET tutor" do
      it "bounces user as not allowed" do
        get :tutor
        expect_bounce_as_not_allowed
      end
    end

  end

  context 'Logged in as a tutor_user: ' do

    before(:each) do
      activate_authlogic
      UserSession.create!(tutor_user)
    end

    describe "GET admin" do
      it "bounces user as not allowed" do
        get :admin
        expect_bounce_as_not_allowed
      end
    end

    describe "GET export_users" do
      it "bounces user as not allowed" do
        get :export_users
        expect_bounce_as_not_allowed
      end
    end

    describe "GET export_users_monthly" do
      it "bounces user as not allowed" do
        get :export_users_monthly
        expect_bounce_as_not_allowed
      end
    end

    describe "GET export_courses" do
      it "bounces user as not allowed" do
        get :export_courses
        expect_bounce_as_not_allowed
      end
    end

    describe "GET content_manager" do
      it "bounces user as not allowed" do
        get :content_manager
        expect_bounce_as_not_allowed
      end
    end

    describe "GET marketing_manager" do
      it "bounces user as not allowed" do
        get :marketing_manager
        expect_bounce_as_not_allowed
      end
    end

    describe "GET customer_support_manager" do
      it "bounces user as not allowed" do
        get :customer_support_manager
        expect_bounce_as_not_allowed
      end
    end

    describe "GET student" do
      it "return http success" do
        get :student
        expect(response).to have_http_status(:success)
        expect(response).to render_template(:student)
      end
    end

    describe "GET tutor" do
      it "bounces user as not allowed" do
        get :tutor
        expect(response).to have_http_status(:success)
        expect(response).to render_template(:tutor)

      end
    end

  end

  context 'Logged in as a blogger_user: ' do

    before(:each) do
      activate_authlogic
      UserSession.create!(blogger_user)
    end

    describe "GET admin" do
      it "bounces user as not allowed" do
        get :admin
        expect_bounce_as_not_allowed
      end
    end

    describe "GET export_users" do
      it "bounces user as not allowed" do
        get :export_users
        expect_bounce_as_not_allowed
      end
    end

    describe "GET export_users_monthly" do
      it "bounces user as not allowed" do
        get :export_users_monthly
        expect_bounce_as_not_allowed
      end
    end

    describe "GET export_courses" do
      it "bounces user as not allowed" do
        get :export_courses
        expect_bounce_as_not_allowed
      end
    end

    describe "GET content_manager" do
      it "bounces user as not allowed" do
        get :content_manager
        expect_bounce_as_not_allowed
      end
    end

    describe "GET marketing_manager" do
      it "bounces user as not allowed" do
        get :marketing_manager
        expect_bounce_as_not_allowed
      end
    end

    describe "GET customer_support_manager" do
      it "bounces user as not allowed" do
        get :customer_support_manager
        expect_bounce_as_not_allowed
      end
    end

    describe "GET student" do
      it "return http success" do
        get :student
        expect(response).to have_http_status(:success)
        expect(response).to render_template(:student)
      end
    end

    describe "GET tutor" do
      it "bounces user as not allowed" do
        get :tutor
        expect_bounce_as_not_allowed

      end
    end
  end

  context 'Logged in as a content_manager_user: ' do

    before(:each) do
      activate_authlogic
      UserSession.create!(content_manager_user)
    end

    describe "GET admin" do
      it "bounces user as not allowed" do
        get :admin
        expect_bounce_as_not_allowed
      end
    end

    describe "GET export_users" do
      it "bounces user as not allowed" do
        get :export_users
        expect_bounce_as_not_allowed
      end
    end

    describe "GET export_users_monthly" do
      it "bounces user as not allowed" do
        get :export_users_monthly
        expect_bounce_as_not_allowed
      end
    end

    describe "GET export_courses" do
      it "bounces user as not allowed" do
        get :export_courses
        expect_bounce_as_not_allowed
      end
    end

    describe "GET content_manager" do
      it "bounces user as not allowed" do
        get :content_manager
        expect(response).to have_http_status(:success)
        expect(response).to render_template(:content_manager)
      end
    end

    describe "GET marketing_manager" do
      it "bounces user as not allowed" do
        get :marketing_manager
        expect_bounce_as_not_allowed
      end
    end

    describe "GET customer_support_manager" do
      it "bounces user as not allowed" do
        get :customer_support_manager
        expect_bounce_as_not_allowed
      end
    end

    describe "GET student" do
      it "return http success" do
        get :student
        expect(response).to have_http_status(:success)
        expect(response).to render_template(:student)
      end
    end

    describe "GET tutor" do
      it "bounces user as not allowed" do
        get :tutor
        expect_bounce_as_not_allowed
      end
    end

  end

  context 'Logged in as a marketing_manager_user: ' do

    before(:each) do
      activate_authlogic
      UserSession.create!(marketing_manager_user)
    end

    describe "GET admin" do
      it "bounces user as not allowed" do
        get :admin
        expect_bounce_as_not_allowed
      end
    end


    describe "GET content_manager" do
      it "bounces user as not allowed" do
        get :content_manager
        expect_bounce_as_not_allowed
      end
    end

    describe "GET marketing_manager" do
      it "bounces user as not allowed" do
        get :marketing_manager
        expect(response).to have_http_status(:success)
        expect(response).to render_template(:marketing_manager)
      end
    end

    describe "GET customer_support_manager" do
      it "bounces user as not allowed" do
        get :customer_support_manager
        expect_bounce_as_not_allowed
      end
    end

    describe "GET student" do
      it "return http success" do
        get :student
        expect(response).to have_http_status(:success)
        expect(response).to render_template(:student)
      end
    end

    describe "GET tutor" do
      it "bounces user as not allowed" do
        get :tutor
        expect_bounce_as_not_allowed
      end
    end

  end

  context 'Logged in as a customer_support_manager_user: ' do

    before(:each) do
      activate_authlogic
      UserSession.create!(customer_support_manager_user)
    end

    describe "GET admin" do
      it "bounces user as not allowed" do
        get :admin
        expect_bounce_as_not_allowed
      end
    end

    describe "GET export_users" do
      it "bounces user as not allowed" do
        get :export_users
        expect_bounce_as_not_allowed
      end
    end

    describe "GET export_users_monthly" do
      it "bounces user as not allowed" do
        get :export_users_monthly
        expect_bounce_as_not_allowed
      end
    end

    describe "GET export_courses" do
      it "bounces user as not allowed" do
        get :export_courses
        expect_bounce_as_not_allowed
      end
    end

    describe "GET content_manager" do
      it "bounces user as not allowed" do
        get :content_manager
        expect_bounce_as_not_allowed
      end
    end

    describe "GET marketing_manager" do
      it "bounces user as not allowed" do
        get :marketing_manager
        expect_bounce_as_not_allowed
      end
    end

    describe "GET customer_support_manager" do
      it "bounces user as not allowed" do
        get :customer_support_manager
        expect(response).to have_http_status(:success)
        expect(response).to render_template(:customer_support_manager)

      end
    end

    describe "GET student" do
      it "return http success" do
        get :student
        expect(response).to have_http_status(:success)
        expect(response).to render_template(:student)
      end
    end

    describe "GET tutor" do
      it "bounces user as not allowed" do
        get :tutor
        expect_bounce_as_not_allowed
      end
    end

  end

  context 'Logged in as a admin_user: ' do

    before(:each) do
      activate_authlogic
      UserSession.create!(admin_user)
    end

    describe "GET admin" do
      it "bounces user as not allowed" do
        get :admin
        expect(response).to have_http_status(:success)
        expect(response).to render_template(:admin)
      end
    end

    describe "GET content_manager" do
      it "bounces user as not allowed" do
        get :content_manager
        expect_bounce_as_not_allowed
      end
    end

    describe "GET marketing_manager" do
      it "bounces user as not allowed" do
        get :marketing_manager
        expect_bounce_as_not_allowed
      end
    end

    describe "GET customer_support_manager" do
      it "bounces user as not allowed" do
        get :customer_support_manager
        expect_bounce_as_not_allowed
      end
    end

    describe "GET student" do
      it "return http success" do
        get :student
        expect(response).to have_http_status(:success)
        expect(response).to render_template(:student)
      end
    end

    describe "GET tutor" do
      it "bounces user as not allowed" do
        get :tutor
        expect_bounce_as_not_allowed
      end
    end
  end

end
