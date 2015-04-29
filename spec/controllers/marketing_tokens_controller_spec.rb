require 'rails_helper'
require 'support/users_and_groups_setup'

describe MarketingTokensController, type: :controller do

  include_context 'users_and_groups_setup'

  # todo: Try to create children for marketing_token_1
  let!(:marketing_token_1) { FactoryGirl.create(:marketing_token) }
  let!(:marketing_token_2) { FactoryGirl.create(:marketing_token) }
  let!(:valid_params) { FactoryGirl.attributes_for(:marketing_token) }

  context 'Not logged in: ' do

    describe "GET 'index'" do
      it 'should redirect to sign_in' do
        get :index
        expect_bounce_as_not_signed_in
      end
    end

    describe "GET 'show/1'" do
      it 'should redirect to sign_in' do
        get :show, id: 1
        expect_bounce_as_not_signed_in
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


    describe "DELETE 'destroy'" do
      it 'should redirect to sign_in' do
        delete :destroy, id: 1
        expect_bounce_as_not_signed_in
      end
    end

  end

  context 'Logged in as a individual_student_user: ' do

    before(:each) do
      activate_authlogic
      UserSession.create!(individual_student_user)
    end

    describe "GET 'index'" do
      it 'should respond OK' do
        get :index
        expect_bounce_as_not_allowed
      end
    end

    describe "GET 'show/1'" do
      it 'should see marketing_token_1' do
        get :show, id: marketing_token_1.id
        expect_bounce_as_not_allowed
      end

      # optional - some other object
      it 'should see marketing_token_2' do
        get :show, id: marketing_token_2.id
        expect_bounce_as_not_allowed
      end
    end

    describe "GET 'new'" do
      it 'should respond OK' do
        get :new
        expect_bounce_as_not_allowed
      end
    end

    describe "GET 'edit/1'" do
      it 'should respond OK with marketing_token_1' do
        get :edit, id: marketing_token_1.id
        expect_bounce_as_not_allowed
      end

      # optional
      it 'should respond OK with marketing_token_2' do
        get :edit, id: marketing_token_2.id
        expect_bounce_as_not_allowed
      end
    end

    describe "POST 'create'" do
      it 'should report OK for valid params' do
        post :create, marketing_token: valid_params
        expect_bounce_as_not_allowed
      end

      it 'should report error for invalid params' do
        post :create, marketing_token: {valid_params.keys.first => ''}
        expect_bounce_as_not_allowed
      end
    end

    describe "PUT 'update/1'" do
      it 'should respond OK to valid params for marketing_token_1' do
        put :update, id: marketing_token_1.id, marketing_token: valid_params
        expect_bounce_as_not_allowed
      end

      # optional
      it 'should respond OK to valid params for marketing_token_2' do
        put :update, id: marketing_token_2.id, marketing_token: valid_params
        expect_bounce_as_not_allowed
      end

      it 'should reject invalid params' do
        put :update, id: marketing_token_1.id, marketing_token: {valid_params.keys.first => ''}
        expect_bounce_as_not_allowed
      end
    end


    describe "DELETE 'destroy'" do
      it 'should be ERROR as children exist' do
        delete :destroy, id: marketing_token_1.id
        expect_bounce_as_not_allowed
      end

      it 'should be OK as no dependencies exist' do
        delete :destroy, id: marketing_token_2.id
        expect_bounce_as_not_allowed
      end
    end

  end

  context 'Logged in as a tutor_user: ' do

    before(:each) do
      activate_authlogic
      UserSession.create!(tutor_user)
    end

    describe "GET 'index'" do
      it 'should respond OK' do
        get :index
        expect_bounce_as_not_allowed
      end
    end

    describe "GET 'show/1'" do
      it 'should see marketing_token_1' do
        get :show, id: marketing_token_1.id
        expect_bounce_as_not_allowed
      end

      # optional - some other object
      it 'should see marketing_token_2' do
        get :show, id: marketing_token_2.id
        expect_bounce_as_not_allowed
      end
    end

    describe "GET 'new'" do
      it 'should respond OK' do
        get :new
        expect_bounce_as_not_allowed
      end
    end

    describe "GET 'edit/1'" do
      it 'should respond OK with marketing_token_1' do
        get :edit, id: marketing_token_1.id
        expect_bounce_as_not_allowed
      end

      # optional
      it 'should respond OK with marketing_token_2' do
        get :edit, id: marketing_token_2.id
        expect_bounce_as_not_allowed
      end
    end

    describe "POST 'create'" do
      it 'should report OK for valid params' do
        post :create, marketing_token: valid_params
        expect_bounce_as_not_allowed
      end

      it 'should report error for invalid params' do
        post :create, marketing_token: {valid_params.keys.first => ''}
        expect_bounce_as_not_allowed
      end
    end

    describe "PUT 'update/1'" do
      it 'should respond OK to valid params for marketing_token_1' do
        put :update, id: marketing_token_1.id, marketing_token: valid_params
        expect_bounce_as_not_allowed
      end

      # optional
      it 'should respond OK to valid params for marketing_token_2' do
        put :update, id: marketing_token_2.id, marketing_token: valid_params
        expect_bounce_as_not_allowed
      end

      it 'should reject invalid params' do
        put :update, id: marketing_token_1.id, marketing_token: {valid_params.keys.first => ''}
        expect_bounce_as_not_allowed
      end
    end


    describe "DELETE 'destroy'" do
      it 'should be ERROR as children exist' do
        delete :destroy, id: marketing_token_1.id
        expect_bounce_as_not_allowed
      end

      it 'should be OK as no dependencies exist' do
        delete :destroy, id: marketing_token_2.id
        expect_bounce_as_not_allowed
      end
    end

  end

  context 'Logged in as a corporate_student_user: ' do

    before(:each) do
      activate_authlogic
      UserSession.create!(corporate_student_user)
    end

    describe "GET 'index'" do
      it 'should respond OK' do
        get :index
        expect_bounce_as_not_allowed
      end
    end

    describe "GET 'show/1'" do
      it 'should see marketing_token_1' do
        get :show, id: marketing_token_1.id
        expect_bounce_as_not_allowed
      end

      # optional - some other object
      it 'should see marketing_token_2' do
        get :show, id: marketing_token_2.id
        expect_bounce_as_not_allowed
      end
    end

    describe "GET 'new'" do
      it 'should respond OK' do
        get :new
        expect_bounce_as_not_allowed
      end
    end

    describe "GET 'edit/1'" do
      it 'should respond OK with marketing_token_1' do
        get :edit, id: marketing_token_1.id
        expect_bounce_as_not_allowed
      end

      # optional
      it 'should respond OK with marketing_token_2' do
        get :edit, id: marketing_token_2.id
        expect_bounce_as_not_allowed
      end
    end

    describe "POST 'create'" do
      it 'should report OK for valid params' do
        post :create, marketing_token: valid_params
        expect_bounce_as_not_allowed
      end

      it 'should report error for invalid params' do
        post :create, marketing_token: {valid_params.keys.first => ''}
        expect_bounce_as_not_allowed
      end
    end

    describe "PUT 'update/1'" do
      it 'should respond OK to valid params for marketing_token_1' do
        put :update, id: marketing_token_1.id, marketing_token: valid_params
        expect_bounce_as_not_allowed
      end

      # optional
      it 'should respond OK to valid params for marketing_token_2' do
        put :update, id: marketing_token_2.id, marketing_token: valid_params
        expect_bounce_as_not_allowed
      end

      it 'should reject invalid params' do
        put :update, id: marketing_token_1.id, marketing_token: {valid_params.keys.first => ''}
        expect_bounce_as_not_allowed
      end
    end


    describe "DELETE 'destroy'" do
      it 'should be ERROR as children exist' do
        delete :destroy, id: marketing_token_1.id
        expect_bounce_as_not_allowed
      end

      it 'should be OK as no dependencies exist' do
        delete :destroy, id: marketing_token_2.id
        expect_bounce_as_not_allowed
      end
    end

  end

  context 'Logged in as a corporate_customer_user: ' do

    before(:each) do
      activate_authlogic
      UserSession.create!(corporate_customer_user)
    end

    describe "GET 'index'" do
      it 'should respond OK' do
        get :index
        expect_bounce_as_not_allowed
      end
    end

    describe "GET 'show/1'" do
      it 'should see marketing_token_1' do
        get :show, id: marketing_token_1.id
        expect_bounce_as_not_allowed
      end

      # optional - some other object
      it 'should see marketing_token_2' do
        get :show, id: marketing_token_2.id
        expect_bounce_as_not_allowed
      end
    end

    describe "GET 'new'" do
      it 'should respond OK' do
        get :new
        expect_bounce_as_not_allowed
      end
    end

    describe "GET 'edit/1'" do
      it 'should respond OK with marketing_token_1' do
        get :edit, id: marketing_token_1.id
        expect_bounce_as_not_allowed
      end

      # optional
      it 'should respond OK with marketing_token_2' do
        get :edit, id: marketing_token_2.id
        expect_bounce_as_not_allowed
      end
    end

    describe "POST 'create'" do
      it 'should report OK for valid params' do
        post :create, marketing_token: valid_params
        expect_bounce_as_not_allowed
      end

      it 'should report error for invalid params' do
        post :create, marketing_token: {valid_params.keys.first => ''}
        expect_bounce_as_not_allowed
      end
    end

    describe "PUT 'update/1'" do
      it 'should respond OK to valid params for marketing_token_1' do
        put :update, id: marketing_token_1.id, marketing_token: valid_params
        expect_bounce_as_not_allowed
      end

      # optional
      it 'should respond OK to valid params for marketing_token_2' do
        put :update, id: marketing_token_2.id, marketing_token: valid_params
        expect_bounce_as_not_allowed
      end

      it 'should reject invalid params' do
        put :update, id: marketing_token_1.id, marketing_token: {valid_params.keys.first => ''}
        expect_bounce_as_not_allowed
      end
    end


    describe "DELETE 'destroy'" do
      it 'should be ERROR as children exist' do
        delete :destroy, id: marketing_token_1.id
        expect_bounce_as_not_allowed
      end

      it 'should be OK as no dependencies exist' do
        delete :destroy, id: marketing_token_2.id
        expect_bounce_as_not_allowed
      end
    end

  end

  context 'Logged in as a blogger_user: ' do

    before(:each) do
      activate_authlogic
      UserSession.create!(blogger_user)
    end

    describe "GET 'index'" do
      it 'should respond OK' do
        get :index
        expect_bounce_as_not_allowed
      end
    end

    describe "GET 'show/1'" do
      it 'should see marketing_token_1' do
        get :show, id: marketing_token_1.id
        expect_bounce_as_not_allowed
      end

      # optional - some other object
      it 'should see marketing_token_2' do
        get :show, id: marketing_token_2.id
        expect_bounce_as_not_allowed
      end
    end

    describe "GET 'new'" do
      it 'should respond OK' do
        get :new
        expect_bounce_as_not_allowed
      end
    end

    describe "GET 'edit/1'" do
      it 'should respond OK with marketing_token_1' do
        get :edit, id: marketing_token_1.id
        expect_bounce_as_not_allowed
      end

      # optional
      it 'should respond OK with marketing_token_2' do
        get :edit, id: marketing_token_2.id
        expect_bounce_as_not_allowed
      end
    end

    describe "POST 'create'" do
      it 'should report OK for valid params' do
        post :create, marketing_token: valid_params
        expect_bounce_as_not_allowed
      end

      it 'should report error for invalid params' do
        post :create, marketing_token: {valid_params.keys.first => ''}
        expect_bounce_as_not_allowed
      end
    end

    describe "PUT 'update/1'" do
      it 'should respond OK to valid params for marketing_token_1' do
        put :update, id: marketing_token_1.id, marketing_token: valid_params
        expect_bounce_as_not_allowed
      end

      # optional
      it 'should respond OK to valid params for marketing_token_2' do
        put :update, id: marketing_token_2.id, marketing_token: valid_params
        expect_bounce_as_not_allowed
      end

      it 'should reject invalid params' do
        put :update, id: marketing_token_1.id, marketing_token: {valid_params.keys.first => ''}
        expect_bounce_as_not_allowed
      end
    end


    describe "DELETE 'destroy'" do
      it 'should be ERROR as children exist' do
        delete :destroy, id: marketing_token_1.id
        expect_bounce_as_not_allowed
      end

      it 'should be OK as no dependencies exist' do
        delete :destroy, id: marketing_token_2.id
        expect_bounce_as_not_allowed
      end
    end

  end

  context 'Logged in as a forum_manager_user: ' do

    before(:each) do
      activate_authlogic
      UserSession.create!(forum_manager_user)
    end

    describe "GET 'index'" do
      it 'should respond OK' do
        get :index
        expect_bounce_as_not_allowed
      end
    end

    describe "GET 'show/1'" do
      it 'should see marketing_token_1' do
        get :show, id: marketing_token_1.id
        expect_bounce_as_not_allowed
      end

      # optional - some other object
      it 'should see marketing_token_2' do
        get :show, id: marketing_token_2.id
        expect_bounce_as_not_allowed
      end
    end

    describe "GET 'new'" do
      it 'should respond OK' do
        get :new
        expect_bounce_as_not_allowed
      end
    end

    describe "GET 'edit/1'" do
      it 'should respond OK with marketing_token_1' do
        get :edit, id: marketing_token_1.id
        expect_bounce_as_not_allowed
      end

      # optional
      it 'should respond OK with marketing_token_2' do
        get :edit, id: marketing_token_2.id
        expect_bounce_as_not_allowed
      end
    end

    describe "POST 'create'" do
      it 'should report OK for valid params' do
        post :create, marketing_token: valid_params
        expect_bounce_as_not_allowed
      end

      it 'should report error for invalid params' do
        post :create, marketing_token: {valid_params.keys.first => ''}
        expect_bounce_as_not_allowed
      end
    end

    describe "PUT 'update/1'" do
      it 'should respond OK to valid params for marketing_token_1' do
        put :update, id: marketing_token_1.id, marketing_token: valid_params
        expect_bounce_as_not_allowed
      end

      # optional
      it 'should respond OK to valid params for marketing_token_2' do
        put :update, id: marketing_token_2.id, marketing_token: valid_params
        expect_bounce_as_not_allowed
      end

      it 'should reject invalid params' do
        put :update, id: marketing_token_1.id, marketing_token: {valid_params.keys.first => ''}
        expect_bounce_as_not_allowed
      end
    end


    describe "DELETE 'destroy'" do
      it 'should be ERROR as children exist' do
        delete :destroy, id: marketing_token_1.id
        expect_bounce_as_not_allowed
      end

      it 'should be OK as no dependencies exist' do
        delete :destroy, id: marketing_token_2.id
        expect_bounce_as_not_allowed
      end
    end

  end

  context 'Logged in as a content_manager_user: ' do

    before(:each) do
      activate_authlogic
      UserSession.create!(content_manager_user)
    end

    describe "GET 'index'" do
      it 'should respond OK' do
        get :index
        expect_bounce_as_not_allowed
      end
    end

    describe "GET 'show/1'" do
      it 'should see marketing_token_1' do
        get :show, id: marketing_token_1.id
        expect_bounce_as_not_allowed
      end

      # optional - some other object
      it 'should see marketing_token_2' do
        get :show, id: marketing_token_2.id
        expect_bounce_as_not_allowed
      end
    end

    describe "GET 'new'" do
      it 'should respond OK' do
        get :new
        expect_bounce_as_not_allowed
      end
    end

    describe "GET 'edit/1'" do
      it 'should respond OK with marketing_token_1' do
        get :edit, id: marketing_token_1.id
        expect_bounce_as_not_allowed
      end

      # optional
      it 'should respond OK with marketing_token_2' do
        get :edit, id: marketing_token_2.id
        expect_bounce_as_not_allowed
      end
    end

    describe "POST 'create'" do
      it 'should report OK for valid params' do
        post :create, marketing_token: valid_params
        expect_bounce_as_not_allowed
      end

      it 'should report error for invalid params' do
        post :create, marketing_token: {valid_params.keys.first => ''}
        expect_bounce_as_not_allowed
      end
    end

    describe "PUT 'update/1'" do
      it 'should respond OK to valid params for marketing_token_1' do
        put :update, id: marketing_token_1.id, marketing_token: valid_params
        expect_bounce_as_not_allowed
      end

      # optional
      it 'should respond OK to valid params for marketing_token_2' do
        put :update, id: marketing_token_2.id, marketing_token: valid_params
        expect_bounce_as_not_allowed
      end

      it 'should reject invalid params' do
        put :update, id: marketing_token_1.id, marketing_token: {valid_params.keys.first => ''}
        expect_bounce_as_not_allowed
      end
    end


    describe "DELETE 'destroy'" do
      it 'should be ERROR as children exist' do
        delete :destroy, id: marketing_token_1.id
        expect_bounce_as_not_allowed
      end

      it 'should be OK as no dependencies exist' do
        delete :destroy, id: marketing_token_2.id
        expect_bounce_as_not_allowed
      end
    end

  end

  context 'Logged in as a admin_user: ' do

    before(:each) do
      activate_authlogic
      UserSession.create!(admin_user)
    end

    describe "GET 'index'" do
      it 'should respond OK' do
        get :index
        expect_index_success_with_model('marketing_tokens', 2)
      end
    end

    describe "GET 'show/1'" do
      it 'should see marketing_token_1' do
        get :show, id: marketing_token_1.id
        expect_show_success_with_model('marketing_token', marketing_token_1.id)
      end

      # optional - some other object
      it 'should see marketing_token_2' do
        get :show, id: marketing_token_2.id
        expect_show_success_with_model('marketing_token', marketing_token_2.id)
      end
    end

    describe "GET 'new'" do
      it 'should respond OK' do
        get :new
        expect_new_success_with_model('marketing_token')
      end
    end

    describe "GET 'edit/1'" do
      it 'should respond OK with marketing_token_1' do
        get :edit, id: marketing_token_1.id
        expect_edit_success_with_model('marketing_token', marketing_token_1.id)
      end

      # optional
      it 'should respond OK with marketing_token_2' do
        get :edit, id: marketing_token_2.id
        expect_edit_success_with_model('marketing_token', marketing_token_2.id)
      end

      it "should redirect to index page for non-editable token" do
        system_token = FactoryGirl.create(:marketing_token, code: 'seo')
        get :edit, id: system_token.id
        expect(response).to redirect_to(marketing_tokens_url)
      end
    end

    describe "POST 'create'" do
      it 'should report OK for valid params' do
        post :create, marketing_token: valid_params
        expect_create_success_with_model('marketing_token', marketing_tokens_url)
      end

      it 'should report error for invalid params' do
        post :create, marketing_token: {valid_params.keys.first => ''}
        expect_create_error_with_model('marketing_token')
      end
    end

    describe "PUT 'update/1'" do
      it 'should respond OK to valid params for marketing_token_1' do
        put :update, id: marketing_token_1.id, marketing_token: valid_params
        expect_update_success_with_model('marketing_token', marketing_tokens_url)
      end

      # optional
      it 'should respond OK to valid params for marketing_token_2' do
        put :update, id: marketing_token_2.id, marketing_token: valid_params
        expect_update_success_with_model('marketing_token', marketing_tokens_url)
        expect(assigns(:marketing_token).id).to eq(marketing_token_2.id)
      end

      it 'should reject invalid params' do
        put :update, id: marketing_token_1.id, marketing_token: {valid_params.keys.first => ''}
        expect_update_error_with_model('marketing_token')
        expect(assigns(:marketing_token).id).to eq(marketing_token_1.id)
      end
    end


    describe "DELETE 'destroy'" do
      it 'should be ERROR for predefined tokens' do
        seo_token = FactoryGirl.create(:marketing_token, code: 'seo')
        delete :destroy, id: seo_token.id
        expect_delete_error_with_model('marketing_token', marketing_tokens_url)

        direct_token = FactoryGirl.create(:marketing_token, code: 'direct')
        delete :destroy, id: direct_token.id
        expect_delete_error_with_model('marketing_token', marketing_tokens_url)
      end

      it 'should be OK as no dependencies exist' do
        delete :destroy, id: marketing_token_2.id
        expect_delete_success_with_model('marketing_token', marketing_tokens_url)
      end
    end

  end

end
