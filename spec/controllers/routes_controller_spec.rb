require 'rails_helper'
require 'support/users_and_groups_setup'
require 'support/course_content'

describe RoutesController, type: :controller do

  include_context 'users_and_groups_setup'
  include_context 'course_content'

  let!(:corporation_1) { FactoryGirl.create(:corporate_customer) }
  let!(:corporation_2) { FactoryGirl.create(:corporate_customer) }

  let!(:valid_params) { FactoryGirl.attributes_for(:corporate_student_user) }

  before(:each) do
    t = tutor_user
    a = admin_user
    cs = corporate_student_user
    cc = corporate_customer_user
  end


  context 'Not logged in: ' do

    describe "GET 'root' with no subdomain" do
      it 'should redirect to home_page#show' do
        get :root
        expect(response.status).to eq(302)
        expect(response).to redirect_to(home_url)
      end
    end

    describe "GET 'root' with a valid subdomain" do
      it 'should redirect to corporate_profiles#show' do
        @request.host = "#{corporation_1.subdomain}.example.com"
        get :root
        expect(response.status).to eq(302)
        expect(response).to redirect_to(corporate_home_url)
      end
    end

  end

  context 'Logged in as a individual_student_user: ' do

    before(:each) do
      activate_authlogic
      UserSession.create!(individual_student_user)
    end

    describe "GET 'root' with no subdomain" do
      it 'should redirect to dashboard#index' do
        get :root
        expect(response.status).to eq(302)
        expect(response).to redirect_to(student_dashboard_url)

      end
    end

    describe "GET 'root' with a valid subdomain" do
      it 'should respond ERROR not permitted' do
        @request.host = "#{corporation_1.subdomain}.example.com"
        get :root
        expect(response.status).to eq(302)
        expect(response).to redirect_to student_dashboard_url

      end
    end


  end

  context 'Logged in as a tutor_user: ' do

    before(:each) do
      activate_authlogic
      UserSession.create!(tutor_user)
    end

    describe "GET 'root' with no subdomain" do
      it 'should redirect to dashboard#index' do
        get :root
        expect(response.status).to eq(302)
        expect(response).to redirect_to(tutor_dashboard_url)
      end
    end

    describe "GET 'root' with a valid subdomain" do
      it 'should redirect to dashboard#index' do
        get :root
        expect(response.status).to eq(302)
        expect(response).to redirect_to(tutor_dashboard_url)
      end
    end

  end

  context 'Logged in as a corporate_customer_user: ' do

    before(:each) do
      activate_authlogic
      UserSession.create!(corporate_customer_user)
    end

    describe "GET 'root' with no subdomain" do
      xit 'should redirect to corporate_customers#show' do
        @request.host = "example.com"
        get :root
        expect(response.status).to eq(302)
        expect(response).to redirect_to corporate_customer_url(corporate_customer_user.corporate_customer.id)
      end
    end

    describe "GET 'root' with a valid subdomain" do
      xit 'should redirect to corporate_customers#show' do
        @request.host = "#{corporation_1.subdomain}.example.com"
        get :root
        expect(response.status).to eq(302)
        expect(response).to redirect_to corporate_customer_url(corporate_customer_user.corporate_customer.id)
      end
    end

  end

  context 'Logged in as a corporate_student_user: ' do

    before(:each) do
      activate_authlogic
      UserSession.create!(corporate_student_user)
    end

    describe "GET 'root' with no subdomain" do
      it 'should redirect to dashboard#index' do
        get :root
        expect(response.status).to eq(302)
        expect(response).to redirect_to(corporate_student_dashboard_url)
      end
    end

    describe "GET 'root' with a valid subdomain" do
      it 'should redirect to dashboard#index' do
        get :root
        expect(response.status).to eq(302)
        expect(response).to redirect_to(corporate_student_dashboard_url)
      end
    end

  end

  context 'Logged in as a forum_manager_user: ' do

    before(:each) do
      activate_authlogic
      UserSession.create!(forum_manager_user)
    end

    describe "GET 'root' with no subdomain" do
      xit 'should redirect to dashboard#index' do
        get :root
        expect(response.status).to eq(302)
        expect(response).to redirect_to(student_dashboard_url)
      end
    end

    describe "GET 'root' with a valid subdomain" do
      xit 'should redirect to dashboard#index' do
        get :root
        expect(response.status).to eq(302)
        expect(response).to redirect_to(student_dashboard_url)
      end
    end

  end

  context 'Logged in as a content_manager_user: ' do

    before(:each) do
      activate_authlogic
      UserSession.create!(content_manager_user)
    end

    describe "GET 'root' with no subdomain" do
      xit 'should redirect to dashboard#index' do
        get :root
        expect(response.status).to eq(302)
        expect(response).to redirect_to(student_dashboard_url)
      end
    end

    describe "GET 'root' with a valid subdomain" do
      xit 'should redirect to dashboard#index' do
        get :root
        expect(response.status).to eq(302)
        expect(response).to redirect_to(student_dashboard_url)
      end
    end

  end

  context 'Logged in as a admin_user: ' do

    before(:each) do
      activate_authlogic
      UserSession.create!(admin_user)
    end

    describe "GET 'root' with no subdomain" do
      it 'should redirect to dashboard#index' do
        get :root
        expect(response.status).to eq(302)
        expect(response).to redirect_to(admin_dashboard_url)
      end
    end

    describe "GET 'root' with a valid subdomain" do
      it 'should redirect to dashboard#index' do
        get :root
        expect(response.status).to eq(302)
        expect(response).to redirect_to(admin_dashboard_url)
      end
    end

  end

end
