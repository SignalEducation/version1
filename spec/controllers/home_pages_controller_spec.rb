# == Schema Information
#
# Table name: home_pages
#
#  id                            :integer          not null, primary key
#  seo_title                     :string
#  seo_description               :string
#  subscription_plan_category_id :integer
#  public_url                    :string
#  created_at                    :datetime         not null
#  updated_at                    :datetime         not null
#  subject_course_id             :integer
#  custom_file_name              :string
#  group_id                      :integer
#  name                          :string
#  discourse_ids                 :string
#  home                          :boolean          default(FALSE)
#

require 'rails_helper'
require 'support/users_and_groups_setup'
require 'support/course_content'
require 'support/system_setup'
require 'mandrill_client'

describe HomePagesController, type: :controller do

  include_context 'course_content'
  include_context 'users_and_groups_setup'
  include_context 'system_setup'

  let!(:home) { FactoryGirl.create(:home, public_url: '/', custom_file_name: 'home') }
  let!(:home_page_1) { FactoryGirl.create(:home_page) }
  let!(:home_page_2) { FactoryGirl.create(:acca_home) }

  let!(:valid_params) { FactoryGirl.attributes_for(:home_page) }

  let!(:sign_up_params) { { first_name: 'Test', last_name: 'Student', locale: 'en',
                            email: 'test.student@example.com', password: 'dummy_pass',
                            password_confirmation: 'dummy_pass' } }
  let!(:default_plan) { FactoryGirl.create(:subscription_plan) }
  let!(:referral_code) { FactoryGirl.create(:referral_code, user_id: student_user.id) }

  context 'Not logged in: ' do

    describe "GET 'new'" do
      it 'should redirect to sign_in' do
        get :new
        expect_bounce_as_not_signed_in
      end
    end

    describe "GET 'edit/1'" do
      it 'should redirect to sign_in' do
        get :edit, id: 1
        expect_bounce_as_not_signed_in
      end
    end

    describe "POST 'create'" do
      it 'should redirect to sign_in' do
        post :create, user: valid_params
        expect_bounce_as_not_signed_in
      end
    end

    describe "PUT 'update/1'" do
      it 'should redirect to sign_in' do
        put :update, id: 1, user: valid_params
        expect_bounce_as_not_signed_in
      end
    end

    describe "GET 'home'" do
      it 'should see home' do
        get :home, home_pages_public_url: '/'
        expect(flash[:success]).to be_nil
        expect(flash[:error]).to be_nil
        expect(response.status).to eq(200)
        expect(response).to render_template(:home)
      end
    end

    describe "GET 'show'" do
      it 'should see show' do
        get :show, home_pages_public_url: home_page_2.public_url
        expect(flash[:success]).to be_nil
        expect(flash[:error]).to be_nil
        expect(response.status).to eq(200)
        expect(response).to render_template(:show)
      end
    end


  end

  context 'Logged in as a student_user: ' do

    before(:each) do
      activate_authlogic
      UserSession.create!(student_user)
    end

    describe "GET 'home'" do
      it 'should see home' do
        get :home
        expect_bounce_to_dashboard_as_signed_in
      end
    end

    describe "GET 'show'" do
      it 'should see show' do
        get :show, home_pages_public_url: home_page_2.public_url
        expect_bounce_to_dashboard_as_signed_in
      end
    end

    describe "GET 'new'" do
      it 'should respond OK' do
        get :new
        expect_bounce_as_not_allowed
      end
    end

    describe "GET 'edit/1'" do
      it 'should respond OK with home_page_1' do
        get :edit, id: home_page_1.id
        expect_bounce_as_not_allowed
      end

      # optional
      it 'should respond OK with home_page_2' do
        get :edit, id: home_page_2.id
        expect_bounce_as_not_allowed
      end
    end

    describe "POST 'create'" do
      it 'should report OK for valid params' do
        post :create, home_page: valid_params
        expect_bounce_as_not_allowed
      end

      it 'should report error for invalid params' do
        post :create, home_page: {valid_params.keys.first => ''}
        expect_bounce_as_not_allowed
      end
    end

    describe "PUT 'update/1'" do
      it 'should respond OK to valid params for home_page_1' do
        put :update, id: home_page_1.id, home_page: valid_params
        expect_bounce_as_not_allowed
      end

      # optional
      it 'should respond OK to valid params for home_page_2' do
        put :update, id: home_page_2.id, home_page: valid_params
        expect_bounce_as_not_allowed
      end

      it 'should reject invalid params' do
        put :update, id: home_page_1.id, home_page: {valid_params.keys.first => ''}
        expect_bounce_as_not_allowed
      end
    end

  end

  context 'Logged in as a complimentary_user: ' do

    before(:each) do
      activate_authlogic
      UserSession.create!(comp_user)
      a = admin_user
      d = content_manager_user
      e = tutor_user
      f = comp_user
      g = customer_support_manager_user
      h = marketing_manager_user
    end

    describe "GET 'home'" do
      it 'should see home' do
        get :home
        expect_bounce_to_dashboard_as_signed_in
      end
    end

    describe "GET 'show'" do
      it 'should see show' do
        get :show, home_pages_public_url: home_page_2.public_url
        expect_bounce_to_dashboard_as_signed_in
      end
    end

    describe "GET 'new'" do
      it 'should respond OK' do
        get :new
        expect_bounce_as_not_allowed
      end
    end

    describe "GET 'edit/1'" do
      it 'should respond OK with home_page_1' do
        get :edit, id: home_page_1.id
        expect_bounce_as_not_allowed
      end

      # optional
      it 'should respond OK with home_page_2' do
        get :edit, id: home_page_2.id
        expect_bounce_as_not_allowed
      end
    end

    describe "POST 'create'" do
      it 'should report OK for valid params' do
        post :create, home_page: valid_params
        expect_bounce_as_not_allowed
      end

      it 'should report error for invalid params' do
        post :create, home_page: {valid_params.keys.first => ''}
        expect_bounce_as_not_allowed
      end
    end

    describe "PUT 'update/1'" do
      it 'should respond OK to valid params for home_page_1' do
        put :update, id: home_page_1.id, home_page: valid_params
        expect_bounce_as_not_allowed
      end

      # optional
      it 'should respond OK to valid params for home_page_2' do
        put :update, id: home_page_2.id, home_page: valid_params
        expect_bounce_as_not_allowed
      end

      it 'should reject invalid params' do
        put :update, id: home_page_1.id, home_page: {valid_params.keys.first => ''}
        expect_bounce_as_not_allowed
      end
    end

  end

  context 'Logged in as a tutor_user: ' do

    before(:each) do
      activate_authlogic
      UserSession.create!(tutor_user)
      a = admin_user
      d = content_manager_user
      e = tutor_user
      f = comp_user
      g = customer_support_manager_user
      h = marketing_manager_user
    end

    describe "GET 'home'" do
      it 'should see home' do
        get :home
        expect_bounce_to_dashboard_as_signed_in
      end
    end

    describe "GET 'show'" do
      it 'should see show' do
        get :show, home_pages_public_url: home_page_2.public_url
        expect_bounce_to_dashboard_as_signed_in
      end
    end

    describe "GET 'new'" do
      it 'should respond OK' do
        get :new
        expect_bounce_as_not_allowed
      end
    end

    describe "GET 'edit/1'" do
      it 'should respond OK with home_page_1' do
        get :edit, id: home_page_1.id
        expect_bounce_as_not_allowed
      end

      # optional
      it 'should respond OK with home_page_2' do
        get :edit, id: home_page_2.id
        expect_bounce_as_not_allowed
      end
    end

    describe "POST 'create'" do
      it 'should report OK for valid params' do
        post :create, home_page: valid_params
        expect_bounce_as_not_allowed
      end

      it 'should report error for invalid params' do
        post :create, home_page: {valid_params.keys.first => ''}
        expect_bounce_as_not_allowed
      end
    end

    describe "PUT 'update/1'" do
      it 'should respond OK to valid params for home_page_1' do
        put :update, id: home_page_1.id, home_page: valid_params
        expect_bounce_as_not_allowed
      end

      # optional
      it 'should respond OK to valid params for home_page_2' do
        put :update, id: home_page_2.id, home_page: valid_params
        expect_bounce_as_not_allowed
      end

      it 'should reject invalid params' do
        put :update, id: home_page_1.id, home_page: {valid_params.keys.first => ''}
        expect_bounce_as_not_allowed
      end
    end

  end

  context 'Logged in as a content_manager_user: ' do

    before(:each) do
      activate_authlogic
      UserSession.create!(content_manager_user)
      a = admin_user
      d = content_manager_user
      e = tutor_user
      f = comp_user
      g = customer_support_manager_user
      h = marketing_manager_user
    end

    describe "GET 'home'" do
      it 'should see home' do
        get :home
        expect_bounce_to_dashboard_as_signed_in
      end
    end

    describe "GET 'show'" do
      it 'should see show' do
        get :show, home_pages_public_url: home_page_2.public_url
        expect_bounce_to_dashboard_as_signed_in
      end
    end

    describe "GET 'new'" do
      it 'should respond OK' do
        get :new
        expect_bounce_as_not_allowed
      end
    end

    describe "GET 'edit/1'" do
      it 'should respond OK with home_page_1' do
        get :edit, id: home_page_1.id
        expect_bounce_as_not_allowed
      end

      # optional
      it 'should respond OK with home_page_2' do
        get :edit, id: home_page_2.id
        expect_bounce_as_not_allowed
      end
    end

    describe "POST 'create'" do
      it 'should report OK for valid params' do
        post :create, home_page: valid_params
        expect_bounce_as_not_allowed
      end

      it 'should report error for invalid params' do
        post :create, home_page: {valid_params.keys.first => ''}
        expect_bounce_as_not_allowed
      end
    end

    describe "PUT 'update/1'" do
      it 'should respond OK to valid params for home_page_1' do
        put :update, id: home_page_1.id, home_page: valid_params
        expect_bounce_as_not_allowed
      end

      # optional
      it 'should respond OK to valid params for home_page_2' do
        put :update, id: home_page_2.id, home_page: valid_params
        expect_bounce_as_not_allowed
      end

      it 'should reject invalid params' do
        put :update, id: home_page_1.id, home_page: {valid_params.keys.first => ''}
        expect_bounce_as_not_allowed
      end
    end

  end

  context 'Logged in as a customer_support_manager_user: ' do

    before(:each) do
      activate_authlogic
      UserSession.create!(customer_support_manager_user)
      a = admin_user
      d = content_manager_user
      e = tutor_user
      f = comp_user
      g = customer_support_manager_user
      h = marketing_manager_user
    end

    describe "GET 'home'" do
      it 'should see home' do
        get :home
        expect_bounce_to_dashboard_as_signed_in
      end
    end

    describe "GET 'show'" do
      it 'should see show' do
        get :show, home_pages_public_url: home_page_2.public_url
        expect_bounce_to_dashboard_as_signed_in
      end
    end

    describe "GET 'new'" do
      it 'should respond OK' do
        get :new
        expect_bounce_as_not_allowed
      end
    end

    describe "GET 'edit/1'" do
      it 'should respond OK with home_page_1' do
        get :edit, id: home_page_1.id
        expect_bounce_as_not_allowed
      end

      # optional
      it 'should respond OK with home_page_2' do
        get :edit, id: home_page_2.id
        expect_bounce_as_not_allowed
      end
    end

    describe "POST 'create'" do
      it 'should report OK for valid params' do
        post :create, home_page: valid_params
        expect_bounce_as_not_allowed
      end

      it 'should report error for invalid params' do
        post :create, home_page: {valid_params.keys.first => ''}
        expect_bounce_as_not_allowed
      end
    end

    describe "PUT 'update/1'" do
      it 'should respond OK to valid params for home_page_1' do
        put :update, id: home_page_1.id, home_page: valid_params
        expect_bounce_as_not_allowed
      end

      # optional
      it 'should respond OK to valid params for home_page_2' do
        put :update, id: home_page_2.id, home_page: valid_params
        expect_bounce_as_not_allowed
      end

      it 'should reject invalid params' do
        put :update, id: home_page_1.id, home_page: {valid_params.keys.first => ''}
        expect_bounce_as_not_allowed
      end
    end

  end

  context 'Logged in as a marketing_manager_user: ' do

    before(:each) do
      activate_authlogic
      UserSession.create!(marketing_manager_user)
      a = admin_user
      d = content_manager_user
      e = tutor_user
      f = comp_user
      g = customer_support_manager_user
      h = marketing_manager_user
    end

    describe "GET 'home'" do
      it 'should see home' do
        get :home
        expect_bounce_to_dashboard_as_signed_in
      end
    end

    describe "GET 'show'" do
      it 'should see show' do
        get :show, home_pages_public_url: home_page_2.public_url
        expect_bounce_to_dashboard_as_signed_in
      end
    end

    describe "GET 'new'" do
      it 'should respond OK' do
        get :new
        expect_bounce_as_not_allowed
      end
    end

    describe "GET 'edit/1'" do
      it 'should respond OK with home_page_1' do
        get :edit, id: home_page_1.id
        expect_bounce_as_not_allowed
      end

      # optional
      it 'should respond OK with home_page_2' do
        get :edit, id: home_page_2.id
        expect_bounce_as_not_allowed
      end
    end

    describe "POST 'create'" do
      it 'should report OK for valid params' do
        post :create, home_page: valid_params
        expect_bounce_as_not_allowed
      end

      it 'should report error for invalid params' do
        post :create, home_page: {valid_params.keys.first => ''}
        expect_bounce_as_not_allowed
      end
    end

    describe "PUT 'update/1'" do
      it 'should respond OK to valid params for home_page_1' do
        put :update, id: home_page_1.id, home_page: valid_params
        expect_bounce_as_not_allowed
      end

      # optional
      it 'should respond OK to valid params for home_page_2' do
        put :update, id: home_page_2.id, home_page: valid_params
        expect_bounce_as_not_allowed
      end

      it 'should reject invalid params' do
        put :update, id: home_page_1.id, home_page: {valid_params.keys.first => ''}
        expect_bounce_as_not_allowed
      end
    end

  end

  context 'Logged in as a admin_user: ' do

    before(:each) do
      activate_authlogic
      UserSession.create!(admin_user)
      a = admin_user
      d = content_manager_user
      e = tutor_user
      f = comp_user
      g = customer_support_manager_user
      h = marketing_manager_user
    end

    describe "GET 'home'" do
      it 'should see home' do
        get :home
        expect_bounce_to_dashboard_as_signed_in
      end
    end

    describe "GET 'show'" do
      it 'should see show' do
        get :show, home_pages_public_url: home_page_2.public_url
        expect_bounce_to_dashboard_as_signed_in
      end
    end

    describe "GET 'new'" do
      it 'should respond OK' do
        get :new
        expect_new_success_with_model('home_page')
      end
    end

    describe "GET 'edit/1'" do
      it 'should respond OK with home_page_1' do
        get :edit, id: home_page_1.id
        expect_edit_success_with_model('home_page', home_page_1.id)
      end

      # optional
      it 'should respond OK with home_page_2' do
        get :edit, id: home_page_2.id
        expect_edit_success_with_model('home_page', home_page_2.id)
      end
    end

    describe "POST 'create'" do
      it 'should report OK for valid params' do
        post :create, home_page: valid_params
        expect_create_success_with_model('home_page', home_pages_url)
      end

      it 'should report error for invalid params' do
        post :create, home_page: {valid_params.keys.first => ''}
        expect_create_error_with_model('home_page')
      end
    end

    describe "PUT 'update/1'" do
      it 'should respond OK to valid params for home_page_1' do
        put :update, id: home_page_1.id, home_page: valid_params
        expect_update_success_with_model('home_page', home_pages_url)
      end

      # optional
      it 'should respond OK to valid params for home_page_2' do
        put :update, id: home_page_2.id, home_page: valid_params
        expect_update_success_with_model('home_page', home_pages_url)
        expect(assigns(:home_page).id).to eq(home_page_2.id)
      end

      it 'should reject invalid params' do
        put :update, id: home_page_1.id, home_page: {valid_params.keys.first => ''}
        expect_update_error_with_model('home_page')
        expect(assigns(:home_page).id).to eq(home_page_1.id)
      end
    end

  end

end
