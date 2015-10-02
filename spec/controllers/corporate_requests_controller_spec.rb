require 'rails_helper'
require 'support/users_and_groups_setup'

describe CorporateRequestsController, type: :controller do

  include_context 'users_and_groups_setup'

  # todo: Try to create children for corporate_request_1
  let!(:corporate_request_1) { FactoryGirl.create(:corporate_request) }
  let!(:corporate_request_2) { FactoryGirl.create(:corporate_request) }
  let!(:valid_params) { FactoryGirl.attributes_for(:corporate_request) }

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
      it 'should respond OK' do
        get :new
        expect_new_success_with_model('corporate_request')
      end
    end

    describe "GET 'edit/1'" do
      it 'should redirect to sign_in' do
        get :edit, id: 1
        expect_bounce_as_not_signed_in
      end
    end

    describe "POST 'create'" do
      it 'should report OK for valid params' do
        request.env['HTTP_REFERER'] = '/'
        post :create, corporate_request: valid_params
        expect(flash[:error]).to be_nil
        expect(flash[:success]).to be_nil
        expect(response.status).to eq(302)
        expect(response).to redirect_to(request.referrer)
        expect(assigns('corporate_request'.to_sym).class.name).to eq('corporate_request'.classify)

      end

      it 'should report error for invalid params' do
        request.env['HTTP_REFERER'] = '/'
        post :create, corporate_request: {valid_params.keys.first => ''}
        expect(flash[:success]).to be_nil
        expect(flash[:error]).to be_nil
        expect(response.status).to eq(302)
        expect(response).to redirect_to(request.referrer)
        expect(assigns('corporate_request'.to_sym).class.name).to eq('corporate_request'.classify)

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
      it 'should see corporate_request_1' do
        get :show, id: corporate_request_1.id
        expect_bounce_as_not_allowed
      end
    end

    describe "GET 'new'" do
      it 'should respond OK' do
        get :new
        expect_new_success_with_model('corporate_request')
      end
    end

    describe "GET 'edit/1'" do
      it 'should respond OK with corporate_request_1' do
        get :edit, id: corporate_request_1.id
        expect_bounce_as_not_allowed
      end

      # optional
      it 'should respond OK with corporate_request_2' do
        get :edit, id: corporate_request_2.id
        expect_bounce_as_not_allowed
      end
    end

    describe "POST 'create'" do
      it 'should report OK for valid params' do
        request.env['HTTP_REFERER'] = '/'
        post :create, corporate_request: valid_params
        expect(flash[:error]).to be_nil
        expect(flash[:success]).to be_nil
        expect(response.status).to eq(302)
        expect(response).to redirect_to(request.referrer)
        expect(assigns('corporate_request'.to_sym).class.name).to eq('corporate_request'.classify)

      end

      it 'should report error for invalid params' do
        request.env['HTTP_REFERER'] = '/'
        post :create, corporate_request: {valid_params.keys.first => ''}
        expect(flash[:success]).to be_nil
        expect(flash[:error]).to be_nil
        expect(response.status).to eq(302)
        expect(response).to redirect_to(request.referrer)
        expect(assigns('corporate_request'.to_sym).class.name).to eq('corporate_request'.classify)

      end
    end

    describe "PUT 'update/1'" do
      it 'should respond OK to valid params for corporate_request_1' do
        put :update, id: corporate_request_1.id, corporate_request: valid_params
        expect_bounce_as_not_allowed
      end

      # optional
      it 'should respond OK to valid params for corporate_request_2' do
        put :update, id: corporate_request_2.id, corporate_request: valid_params
        expect_bounce_as_not_allowed
      end

      it 'should reject invalid params' do
        put :update, id: corporate_request_1.id, corporate_request: {valid_params.keys.first => ''}
        expect_bounce_as_not_allowed
      end
    end


    describe "DELETE 'destroy'" do
      it 'should be ERROR as children exist' do
        delete :destroy, id: corporate_request_1.id
        expect_bounce_as_not_allowed
      end

      it 'should be OK as no dependencies exist' do
        delete :destroy, id: corporate_request_2.id
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
      it 'should see corporate_request_1' do
        get :show, id: corporate_request_1.id
        expect_bounce_as_not_allowed
      end

      # optional - some other object
      it 'should see corporate_request_2' do
        get :show, id: corporate_request_2.id
        expect_bounce_as_not_allowed
      end
    end

    describe "GET 'new'" do
      it 'should respond OK' do
        get :new
        expect_new_success_with_model('corporate_request')
      end
    end

    describe "GET 'edit/1'" do
      it 'should respond OK with corporate_request_1' do
        get :edit, id: corporate_request_1.id
        expect_bounce_as_not_allowed
      end

      # optional
      it 'should respond OK with corporate_request_2' do
        get :edit, id: corporate_request_2.id
        expect_bounce_as_not_allowed
      end
    end

    describe "POST 'create'" do
      it 'should report OK for valid params' do
        request.env['HTTP_REFERER'] = '/'
        post :create, corporate_request: valid_params
        expect(flash[:error]).to be_nil
        expect(flash[:success]).to be_nil
        expect(response.status).to eq(302)
        expect(response).to redirect_to(request.referrer)
        expect(assigns('corporate_request'.to_sym).class.name).to eq('corporate_request'.classify)

      end

      it 'should report error for invalid params' do
        request.env['HTTP_REFERER'] = '/'
        post :create, corporate_request: {valid_params.keys.first => ''}
        expect(flash[:success]).to be_nil
        expect(flash[:error]).to be_nil
        expect(response.status).to eq(302)
        expect(response).to redirect_to(request.referrer)
        expect(assigns('corporate_request'.to_sym).class.name).to eq('corporate_request'.classify)

      end
    end

    describe "PUT 'update/1'" do
      it 'should respond OK to valid params for corporate_request_1' do
        put :update, id: corporate_request_1.id, corporate_request: valid_params
        expect_bounce_as_not_allowed
      end

      # optional
      it 'should respond OK to valid params for corporate_request_2' do
        put :update, id: corporate_request_2.id, corporate_request: valid_params
        expect_bounce_as_not_allowed
      end

      it 'should reject invalid params' do
        put :update, id: corporate_request_1.id, corporate_request: {valid_params.keys.first => ''}
        expect_bounce_as_not_allowed
      end
    end


    describe "DELETE 'destroy'" do
      it 'should be ERROR as children exist' do
        delete :destroy, id: corporate_request_1.id
        expect_bounce_as_not_allowed
      end

      it 'should be OK as no dependencies exist' do
        delete :destroy, id: corporate_request_2.id
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
      it 'should see corporate_request_1' do
        get :show, id: corporate_request_1.id
        expect_bounce_as_not_allowed
      end

      # optional - some other object
      it 'should see corporate_request_2' do
        get :show, id: corporate_request_2.id
        expect_bounce_as_not_allowed
      end
    end

    describe "GET 'new'" do
      it 'should respond OK' do
        get :new
        expect_new_success_with_model('corporate_request')
      end
    end

    describe "GET 'edit/1'" do
      it 'should respond OK with corporate_request_1' do
        get :edit, id: corporate_request_1.id
        expect_bounce_as_not_allowed
      end

      # optional
      it 'should respond OK with corporate_request_2' do
        get :edit, id: corporate_request_2.id
        expect_bounce_as_not_allowed
      end
    end

    describe "POST 'create'" do
      it 'should report OK for valid params' do
        request.env['HTTP_REFERER'] = '/'
        post :create, corporate_request: valid_params
        expect(flash[:error]).to be_nil
        expect(flash[:success]).to be_nil
        expect(response.status).to eq(302)
        expect(response).to redirect_to(request.referrer)
        expect(assigns('corporate_request'.to_sym).class.name).to eq('corporate_request'.classify)

      end

      it 'should report error for invalid params' do
        request.env['HTTP_REFERER'] = '/'
        post :create, corporate_request: {valid_params.keys.first => ''}
        expect(flash[:success]).to be_nil
        expect(flash[:error]).to be_nil
        expect(response.status).to eq(302)
        expect(response).to redirect_to(request.referrer)
        expect(assigns('corporate_request'.to_sym).class.name).to eq('corporate_request'.classify)

      end
    end

    describe "PUT 'update/1'" do
      it 'should respond OK to valid params for corporate_request_1' do
        put :update, id: corporate_request_1.id, corporate_request: valid_params
        expect_bounce_as_not_allowed
      end

      # optional
      it 'should respond OK to valid params for corporate_request_2' do
        put :update, id: corporate_request_2.id, corporate_request: valid_params
        expect_bounce_as_not_allowed
      end

      it 'should reject invalid params' do
        put :update, id: corporate_request_1.id, corporate_request: {valid_params.keys.first => ''}
        expect_bounce_as_not_allowed
      end
    end


    describe "DELETE 'destroy'" do
      it 'should be ERROR as children exist' do
        delete :destroy, id: corporate_request_1.id
        expect_bounce_as_not_allowed
      end

      it 'should be OK as no dependencies exist' do
        delete :destroy, id: corporate_request_2.id
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
      it 'should see corporate_request_1' do
        get :show, id: corporate_request_1.id
        expect_bounce_as_not_allowed
      end

      # optional - some other object
      it 'should see corporate_request_2' do
        get :show, id: corporate_request_2.id
        expect_bounce_as_not_allowed
      end
    end

    describe "GET 'new'" do
      it 'should respond OK' do
        get :new
        expect_new_success_with_model('corporate_request')
      end
    end

    describe "GET 'edit/1'" do
      it 'should respond OK with corporate_request_1' do
        get :edit, id: corporate_request_1.id
        expect_bounce_as_not_allowed
      end

      # optional
      it 'should respond OK with corporate_request_2' do
        get :edit, id: corporate_request_2.id
        expect_bounce_as_not_allowed
      end
    end

    describe "POST 'create'" do
      it 'should report OK for valid params' do
        request.env['HTTP_REFERER'] = '/'
        post :create, corporate_request: valid_params
        expect(flash[:error]).to be_nil
        expect(flash[:success]).to be_nil
        expect(response.status).to eq(302)
        expect(response).to redirect_to(request.referrer)
        expect(assigns('corporate_request'.to_sym).class.name).to eq('corporate_request'.classify)

      end

      it 'should report error for invalid params' do
        request.env['HTTP_REFERER'] = '/'
        post :create, corporate_request: {valid_params.keys.first => ''}
        expect(flash[:success]).to be_nil
        expect(flash[:error]).to be_nil
        expect(response.status).to eq(302)
        expect(response).to redirect_to(request.referrer)
        expect(assigns('corporate_request'.to_sym).class.name).to eq('corporate_request'.classify)

      end
    end

    describe "PUT 'update/1'" do
      it 'should respond OK to valid params for corporate_request_1' do
        put :update, id: corporate_request_1.id, corporate_request: valid_params
        expect_bounce_as_not_allowed
      end

      # optional
      it 'should respond OK to valid params for corporate_request_2' do
        put :update, id: corporate_request_2.id, corporate_request: valid_params
        expect_bounce_as_not_allowed
      end

      it 'should reject invalid params' do
        put :update, id: corporate_request_1.id, corporate_request: {valid_params.keys.first => ''}
        expect_bounce_as_not_allowed
      end
    end


    describe "DELETE 'destroy'" do
      it 'should be ERROR as children exist' do
        delete :destroy, id: corporate_request_1.id
        expect_bounce_as_not_allowed
      end

      it 'should be OK as no dependencies exist' do
        delete :destroy, id: corporate_request_2.id
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
      it 'should see corporate_request_1' do
        get :show, id: corporate_request_1.id
        expect_bounce_as_not_allowed
      end

      # optional - some other object
      it 'should see corporate_request_2' do
        get :show, id: corporate_request_2.id
        expect_bounce_as_not_allowed
      end
    end

    describe "GET 'new'" do
      it 'should respond OK' do
        get :new
        expect_new_success_with_model('corporate_request')
      end
    end

    describe "GET 'edit/1'" do
      it 'should respond OK with corporate_request_1' do
        get :edit, id: corporate_request_1.id
        expect_bounce_as_not_allowed
      end

      # optional
      it 'should respond OK with corporate_request_2' do
        get :edit, id: corporate_request_2.id
        expect_bounce_as_not_allowed
      end
    end

    describe "POST 'create'" do
      it 'should report OK for valid params' do
        request.env['HTTP_REFERER'] = '/'
        post :create, corporate_request: valid_params
        expect(flash[:error]).to be_nil
        expect(flash[:success]).to be_nil
        expect(response.status).to eq(302)
        expect(response).to redirect_to(request.referrer)
        expect(assigns('corporate_request'.to_sym).class.name).to eq('corporate_request'.classify)

      end

      it 'should report error for invalid params' do
        request.env['HTTP_REFERER'] = '/'
        post :create, corporate_request: {valid_params.keys.first => ''}
        expect(flash[:success]).to be_nil
        expect(flash[:error]).to be_nil
        expect(response.status).to eq(302)
        expect(response).to redirect_to(request.referrer)
        expect(assigns('corporate_request'.to_sym).class.name).to eq('corporate_request'.classify)

      end
    end

    describe "PUT 'update/1'" do
      it 'should respond OK to valid params for corporate_request_1' do
        put :update, id: corporate_request_1.id, corporate_request: valid_params
        expect_bounce_as_not_allowed
      end

      # optional
      it 'should respond OK to valid params for corporate_request_2' do
        put :update, id: corporate_request_2.id, corporate_request: valid_params
        expect_bounce_as_not_allowed
      end

      it 'should reject invalid params' do
        put :update, id: corporate_request_1.id, corporate_request: {valid_params.keys.first => ''}
        expect_bounce_as_not_allowed
      end
    end


    describe "DELETE 'destroy'" do
      it 'should be ERROR as children exist' do
        delete :destroy, id: corporate_request_1.id
        expect_bounce_as_not_allowed
      end

      it 'should be OK as no dependencies exist' do
        delete :destroy, id: corporate_request_2.id
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
      it 'should see corporate_request_1' do
        get :show, id: corporate_request_1.id
        expect_bounce_as_not_allowed
      end

      # optional - some other object
      it 'should see corporate_request_2' do
        get :show, id: corporate_request_2.id
        expect_bounce_as_not_allowed
      end
    end

    describe "GET 'new'" do
      it 'should respond OK' do
        get :new
        expect_new_success_with_model('corporate_request')
      end
    end

    describe "GET 'edit/1'" do
      it 'should respond OK with corporate_request_1' do
        get :edit, id: corporate_request_1.id
        expect_bounce_as_not_allowed
      end

      # optional
      it 'should respond OK with corporate_request_2' do
        get :edit, id: corporate_request_2.id
        expect_bounce_as_not_allowed
      end
    end

    describe "POST 'create'" do
      it 'should report OK for valid params' do
        request.env['HTTP_REFERER'] = '/'
        post :create, corporate_request: valid_params
        expect(flash[:error]).to be_nil
        expect(flash[:success]).to be_nil
        expect(response.status).to eq(302)
        expect(response).to redirect_to(request.referrer)
        expect(assigns('corporate_request'.to_sym).class.name).to eq('corporate_request'.classify)

      end

      it 'should report error for invalid params' do
        request.env['HTTP_REFERER'] = '/'
        post :create, corporate_request: {valid_params.keys.first => ''}
        expect(flash[:success]).to be_nil
        expect(flash[:error]).to be_nil
        expect(response.status).to eq(302)
        expect(response).to redirect_to(request.referrer)
        expect(assigns('corporate_request'.to_sym).class.name).to eq('corporate_request'.classify)

      end
    end

    describe "PUT 'update/1'" do
      it 'should respond OK to valid params for corporate_request_1' do
        put :update, id: corporate_request_1.id, corporate_request: valid_params
        expect_bounce_as_not_allowed
      end

      # optional
      it 'should respond OK to valid params for corporate_request_2' do
        put :update, id: corporate_request_2.id, corporate_request: valid_params
        expect_bounce_as_not_allowed
      end

      it 'should reject invalid params' do
        put :update, id: corporate_request_1.id, corporate_request: {valid_params.keys.first => ''}
        expect_bounce_as_not_allowed
      end
    end


    describe "DELETE 'destroy'" do
      it 'should be ERROR as children exist' do
        delete :destroy, id: corporate_request_1.id
        expect_bounce_as_not_allowed
      end

      it 'should be OK as no dependencies exist' do
        delete :destroy, id: corporate_request_2.id
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
      it 'should see corporate_request_1' do
        get :show, id: corporate_request_1.id
        expect_bounce_as_not_allowed
      end

      # optional - some other object
      it 'should see corporate_request_2' do
        get :show, id: corporate_request_2.id
        expect_bounce_as_not_allowed
      end
    end

    describe "GET 'new'" do
      it 'should respond OK' do
        get :new
        expect_new_success_with_model('corporate_request')
      end
    end

    describe "GET 'edit/1'" do
      it 'should respond OK with corporate_request_1' do
        get :edit, id: corporate_request_1.id
        expect_bounce_as_not_allowed
      end

      # optional
      it 'should respond OK with corporate_request_2' do
        get :edit, id: corporate_request_2.id
        expect_bounce_as_not_allowed
      end
    end

    describe "POST 'create'" do
      it 'should report OK for valid params' do
        request.env['HTTP_REFERER'] = '/'
        post :create, corporate_request: valid_params
        expect(flash[:error]).to be_nil
        expect(flash[:success]).to be_nil
        expect(response.status).to eq(302)
        expect(response).to redirect_to(request.referrer)
        expect(assigns('corporate_request'.to_sym).class.name).to eq('corporate_request'.classify)

      end

      it 'should report error for invalid params' do
        request.env['HTTP_REFERER'] = '/'
        post :create, corporate_request: {valid_params.keys.first => ''}
        expect(flash[:success]).to be_nil
        expect(flash[:error]).to be_nil
        expect(response.status).to eq(302)
        expect(response).to redirect_to(request.referrer)
        expect(assigns('corporate_request'.to_sym).class.name).to eq('corporate_request'.classify)

      end
    end

    describe "PUT 'update/1'" do
      it 'should respond OK to valid params for corporate_request_1' do
        put :update, id: corporate_request_1.id, corporate_request: valid_params
        expect_bounce_as_not_allowed
      end

      # optional
      it 'should respond OK to valid params for corporate_request_2' do
        put :update, id: corporate_request_2.id, corporate_request: valid_params
        expect_bounce_as_not_allowed
      end

      it 'should reject invalid params' do
        put :update, id: corporate_request_1.id, corporate_request: {valid_params.keys.first => ''}
        expect_bounce_as_not_allowed
      end
    end


    describe "DELETE 'destroy'" do
      it 'should be ERROR as children exist' do
        delete :destroy, id: corporate_request_1.id
        expect_bounce_as_not_allowed
      end

      it 'should be OK as no dependencies exist' do
        delete :destroy, id: corporate_request_2.id
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
        expect_index_success_with_model('corporate_requests', 2)
      end
    end

    describe "GET 'show/1'" do
      it 'should see corporate_request_1' do
        get :show, id: corporate_request_1.id
        expect_show_success_with_model('corporate_request', corporate_request_1.id)
      end

      # optional - some other object
      it 'should see corporate_request_2' do
        get :show, id: corporate_request_2.id
        expect_show_success_with_model('corporate_request', corporate_request_2.id)
      end
    end

    describe "GET 'new'" do
      it 'should respond OK' do
        get :new
        expect_new_success_with_model('corporate_request')
      end
    end

    describe "GET 'edit/1'" do
      it 'should respond OK with corporate_request_1' do
        get :edit, id: corporate_request_1.id
        expect_edit_success_with_model('corporate_request', corporate_request_1.id)
      end

      # optional
      it 'should respond OK with corporate_request_2' do
        get :edit, id: corporate_request_2.id
        expect_edit_success_with_model('corporate_request', corporate_request_2.id)
      end
    end

    describe "POST 'create'" do
      it 'should report OK for valid params' do
        request.env['HTTP_REFERER'] = '/'
        post :create, corporate_request: valid_params
        expect(flash[:error]).to be_nil
        expect(flash[:success]).to be_nil
        expect(response.status).to eq(302)
        expect(response).to redirect_to(request.referrer)
        expect(assigns('corporate_request'.to_sym).class.name).to eq('corporate_request'.classify)

      end

      it 'should report error for invalid params' do
        request.env['HTTP_REFERER'] = '/'
        post :create, corporate_request: {valid_params.keys.first => ''}
        expect(flash[:success]).to be_nil
        expect(flash[:error]).to be_nil
        expect(response.status).to eq(302)
        expect(response).to redirect_to(request.referrer)
        expect(assigns('corporate_request'.to_sym).class.name).to eq('corporate_request'.classify)

      end
    end

    describe "PUT 'update/1'" do
      it 'should respond OK to valid params for corporate_request_1' do
        put :update, id: corporate_request_1.id, corporate_request: valid_params
        expect_update_success_with_model('corporate_request', corporate_requests_url)
      end

      # optional
      it 'should respond OK to valid params for corporate_request_2' do
        put :update, id: corporate_request_2.id, corporate_request: valid_params
        expect_update_success_with_model('corporate_request', corporate_requests_url)
        expect(assigns(:corporate_request).id).to eq(corporate_request_2.id)
      end

      it 'should reject invalid params' do
        put :update, id: corporate_request_1.id, corporate_request: {valid_params.keys.first => ''}
        expect_update_error_with_model('corporate_request')
        expect(assigns(:corporate_request).id).to eq(corporate_request_1.id)
      end
    end


    describe "DELETE 'destroy'" do
      it 'should be OK as no dependencies exist' do
        delete :destroy, id: corporate_request_2.id
        expect_delete_success_with_model('corporate_request', corporate_requests_url)
      end
    end

  end

end
