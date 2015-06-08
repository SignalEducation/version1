require 'rails_helper'
require 'support/users_and_groups_setup'

describe HomePagesController, type: :controller do

  include_context 'users_and_groups_setup'

  # todo: Try to create children for home_page_1
  let!(:home_page_1) { FactoryGirl.create(:home_page) }
  let!(:home_page_2) { FactoryGirl.create(:home_page) }
  let!(:valid_params) { FactoryGirl.attributes_for(:home_page) }

  context 'Not logged in: ' do

    describe "GET 'show/1'" do
      it 'should see home_page_1' do
        get :show, id: home_page_1.id
        expect_show_success_with_model('home_page', home_page_1.id)
      end
    end

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


  end

  context 'Logged in as a individual_student_user: ' do

    before(:each) do
      activate_authlogic
      UserSession.create!(individual_student_user)
    end

    describe "GET 'show/1'" do

      it 'should see home_page_1' do
        get :show, id: home_page_1.id
        expect_show_success_with_model('home_page', home_page_1.id)
      end

      it 'should see home_page_2' do
        get :show, id: home_page_2.id
        expect_show_success_with_model('home_page', home_page_2.id)
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
    end

    describe "GET 'show/1'" do
      it 'should see home_page_1' do
        get :show, id: home_page_1.id
        expect_show_success_with_model('home_page', home_page_1.id)
      end

      # optional - some other object
      it 'should see home_page_2' do
        get :show, id: home_page_2.id
        expect_show_success_with_model('home_page', home_page_2.id)
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

  context 'Logged in as a corporate_student_user: ' do

    before(:each) do
      activate_authlogic
      UserSession.create!(corporate_student_user)
    end

    describe "GET 'show/1'" do
      it 'should see home_page_1' do
        get :show, id: home_page_1.id
        expect_show_success_with_model('home_page', home_page_1.id)
      end

      # optional - some other object
      it 'should see home_page_2' do
        get :show, id: home_page_2.id
        expect_show_success_with_model('home_page', home_page_2.id)
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

  context 'Logged in as a corporate_customer_user: ' do

    before(:each) do
      activate_authlogic
      UserSession.create!(corporate_customer_user)
    end

    describe "GET 'show/1'" do
      it 'should see home_page_1' do
        get :show, id: home_page_1.id
        expect_show_success_with_model('home_page', home_page_1.id)
      end

      # optional - some other object
      it 'should see home_page_2' do
        get :show, id: home_page_2.id
        expect_show_success_with_model('home_page', home_page_2.id)
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

  context 'Logged in as a blogger_user: ' do

    before(:each) do
      activate_authlogic
      UserSession.create!(blogger_user)
    end

    describe "GET 'show/1'" do
      it 'should see home_page_1' do
        get :show, id: home_page_1.id
        expect_show_success_with_model('home_page', home_page_1.id)
      end

      # optional - some other object
      it 'should see home_page_2' do
        get :show, id: home_page_2.id
        expect_show_success_with_model('home_page', home_page_2.id)
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

  context 'Logged in as a forum_manager_user: ' do

    before(:each) do
      activate_authlogic
      UserSession.create!(forum_manager_user)
    end

    describe "GET 'show/1'" do
      it 'should see home_page_1' do
        get :show, id: home_page_1.id
        expect_show_success_with_model('home_page', home_page_1.id)
      end

      # optional - some other object
      it 'should see home_page_2' do
        get :show, id: home_page_2.id
        expect_show_success_with_model('home_page', home_page_2.id)
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
    end

    describe "GET 'show/1'" do
      it 'should see home_page_1' do
        get :show, id: home_page_1.id
        expect_show_success_with_model('home_page', home_page_1.id)
      end

      # optional - some other object
      it 'should see home_page_2' do
        get :show, id: home_page_2.id
        expect_show_success_with_model('home_page', home_page_2.id)
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
    end

    describe "GET 'show/1'" do
      it 'should see home_page_1' do
        get :show, id: home_page_1.id
        expect_show_success_with_model('home_page', home_page_1.id)
      end

      # optional - some other object
      it 'should see home_page_2' do
        get :show, id: home_page_2.id
        expect_show_success_with_model('home_page', home_page_2.id)
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
