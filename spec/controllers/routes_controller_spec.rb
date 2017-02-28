require 'rails_helper'
require 'support/users_and_groups_setup'
require 'support/course_content'

describe RoutesController, type: :controller do

  include_context 'users_and_groups_setup'
  include_context 'course_content'

  before(:each) do
    t = tutor_user
    a = admin_user
    cm = content_manager_user
    cu = comp_user
    cs = customer_support_manager_user
    mm = marketing_manager_user
  end

  context 'Not logged in: ' do

    describe "GET 'root'" do
      it 'should redirect to home_page#show' do
        get :root
        expect(response.status).to eq(302)
        expect(response).to redirect_to(home_url)
      end
    end

  end

  context 'Logged in as a individual_student_user: ' do

    before(:each) do
      activate_authlogic
      UserSession.create!(individual_student_user)
    end

    describe "GET 'root'" do
      it 'should redirect to dashboard#index' do
        get :root
        expect(response.status).to eq(302)
        expect(response).to redirect_to(student_dashboard_url)

      end
    end

  end

  context 'Logged in as a complimentary_user: ' do

    before(:each) do
      activate_authlogic
      UserSession.create!(comp_user)
    end

    describe "GET 'root'" do
      it 'should redirect to dashboard#index' do
        get :root
        expect(response.status).to eq(302)
        expect(response).to redirect_to(student_dashboard_url)

      end
    end

  end

  context 'Logged in as a tutor_user: ' do

    before(:each) do
      activate_authlogic
      UserSession.create!(tutor_user)
    end

    describe "GET 'root'" do
      it 'should redirect to dashboard#index' do
        get :root
        expect(response.status).to eq(302)
        expect(response).to redirect_to(tutor_dashboard_url)
      end
    end

  end

  context 'Logged in as a content_manager_user: ' do

    before(:each) do
      activate_authlogic
      UserSession.create!(content_manager_user)
    end

    describe "GET 'root'" do
      it 'should redirect to dashboard#index' do
        get :root
        expect(response.status).to eq(302)
        expect(response).to redirect_to(content_manager_dashboard_url)
      end
    end

  end

  context 'Logged in as a customer_support_manager_user: ' do

    before(:each) do
      activate_authlogic
      UserSession.create!(customer_support_manager_user)
    end

    describe "GET 'root'" do
      it 'should redirect to dashboard#index' do
        get :root
        expect(response.status).to eq(302)
        expect(response).to redirect_to(customer_support_manager_dashboard_url)
      end
    end

  end

  context 'Logged in as a marketing_manager_user: ' do

    before(:each) do
      activate_authlogic
      UserSession.create!(marketing_manager_user)
    end

    describe "GET 'root'" do
      it 'should redirect to dashboard#index' do
        get :root
        expect(response.status).to eq(302)
        expect(response).to redirect_to(marketing_manager_dashboard_url)
      end
    end

  end

  context 'Logged in as a admin_user: ' do

    before(:each) do
      activate_authlogic
      UserSession.create!(admin_user)
    end

    describe "GET 'root'" do
      it 'should redirect to dashboard#index' do
        get :root
        expect(response.status).to eq(302)
        expect(response).to redirect_to(admin_dashboard_url)
      end
    end

  end

end
