# == Schema Information
#
# Table name: tutor_applications
#
#  id          :integer          not null, primary key
#  first_name  :string
#  last_name   :string
#  email       :string
#  info        :text
#  description :text
#  created_at  :datetime         not null
#  updated_at  :datetime         not null
#

require 'rails_helper'
require 'support/users_and_groups_setup'

describe TutorApplicationsController, type: :controller do

  include_context 'users_and_groups_setup'

  let!(:tutor_application_1) { FactoryGirl.create(:tutor_application) }
  let!(:tutor_application_2) { FactoryGirl.create(:tutor_application) }
  let!(:valid_params) { FactoryGirl.attributes_for(:tutor_application) }

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
      it 'should return success with new' do
        get :new
        expect_new_success_with_model('tutor_application')
      end
    end

    describe "POST 'create'" do
      it 'should return create success and redirect new again' do
        post :create, tutor_application: valid_params
        expect(flash[:error]).to be_nil
        expect(flash[:success]).to eq(I18n.t('controllers.tutor_applications.create.flash.success'))
        expect(response.status).to eq(302)
        expect(response).to redirect_to(new_tutor_application_url)
        expect(assigns(('tutor_application').to_sym).class.name).to eq(('tutor_application').classify)
      end
    end

    describe "PUT 'update/1'" do
      it 'should respond OK to valid params for tutor_application_1' do
        put :update, id: tutor_application_1.id, tutor_application: valid_params
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
      it 'should reject as not allowed' do
        get :index
        expect_bounce_as_not_allowed
      end
    end

    describe "GET 'show/1'" do
      it 'should reject as not allowed' do
        get :show, id: tutor_application_1.id
        expect_bounce_as_not_allowed
      end

      # optional - some other object
      it 'should reject as not allowed' do
        get :show, id: tutor_application_2.id
        expect_bounce_as_not_allowed
      end
    end

    describe "GET 'new'" do
      it 'should respond OK' do
        get :new
        expect_new_success_with_model('tutor_application')
      end
    end

    describe "POST 'create'" do
      it 'should report OK for valid params' do
        post :create, tutor_application: valid_params
        expect(flash[:error]).to be_nil
        expect(flash[:success]).to eq(I18n.t('controllers.tutor_applications.create.flash.success'))
        expect(response.status).to eq(302)
        expect(response).to redirect_to(new_tutor_application_url)
        expect(assigns(('tutor_application').to_sym).class.name).to eq(('tutor_application').classify)
      end

      it 'should report error for invalid params' do
        post :create, tutor_application: {valid_params.keys.first => ''}
        expect_create_error_with_model('tutor_application')
      end
    end

    describe "PUT 'update/1'" do
      it 'should reject as not allowed' do
        put :update, id: tutor_application_1.id, tutor_application: valid_params
        expect_bounce_as_not_allowed
      end

      it 'should reject as not allowed' do
        put :update, id: tutor_application_1.id, tutor_application: {valid_params.keys.first => ''}
        expect_bounce_as_not_allowed
      end
    end


    describe "DELETE 'destroy'" do
      it 'should be ERROR as children exist' do
        delete :destroy, id: tutor_application_1.id
        expect_bounce_as_not_allowed
      end

      it 'should be OK as no dependencies exist' do
        delete :destroy, id: tutor_application_2.id
        expect_bounce_as_not_allowed
      end
    end

  end

  context 'Logged in as a complimentary_user: ' do

    before(:each) do
      activate_authlogic
      UserSession.create!(comp_user)
    end

    describe "GET 'index'" do
      it 'should reject as not allowed' do
        get :index
        expect_bounce_as_not_allowed
      end
    end

    describe "GET 'show/1'" do
      it 'should reject as not allowed' do
        get :show, id: tutor_application_1.id
        expect_bounce_as_not_allowed
      end

      # optional - some other object
      it 'should reject as not allowed' do
        get :show, id: tutor_application_2.id
        expect_bounce_as_not_allowed
      end
    end

    describe "GET 'new'" do
      it 'should respond OK' do
        get :new
        expect_new_success_with_model('tutor_application')
      end
    end

    describe "POST 'create'" do
      it 'should report OK for valid params' do
        post :create, tutor_application: valid_params
        expect(flash[:error]).to be_nil
        expect(flash[:success]).to eq(I18n.t('controllers.tutor_applications.create.flash.success'))
        expect(response.status).to eq(302)
        expect(response).to redirect_to(new_tutor_application_url)
        expect(assigns(('tutor_application').to_sym).class.name).to eq(('tutor_application').classify)
      end

      it 'should report error for invalid params' do
        post :create, tutor_application: {valid_params.keys.first => ''}
        expect_create_error_with_model('tutor_application')
      end
    end

    describe "PUT 'update/1'" do
      it 'should reject as not allowed' do
        put :update, id: tutor_application_1.id, tutor_application: valid_params
        expect_bounce_as_not_allowed
      end

      it 'should reject as not allowed' do
        put :update, id: tutor_application_1.id, tutor_application: {valid_params.keys.first => ''}
        expect_bounce_as_not_allowed
      end
    end


    describe "DELETE 'destroy'" do
      it 'should be ERROR as children exist' do
        delete :destroy, id: tutor_application_1.id
        expect_bounce_as_not_allowed
      end

      it 'should be OK as no dependencies exist' do
        delete :destroy, id: tutor_application_2.id
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
      it 'should reject as not allowed' do
        get :index
        expect_bounce_as_not_allowed
      end
    end

    describe "GET 'show/1'" do
      it 'should reject as not allowed' do
        get :show, id: tutor_application_1.id
        expect_bounce_as_not_allowed
      end
    end

    describe "GET 'new'" do
      it 'should respond OK' do
        get :new
        expect_new_success_with_model('tutor_application')
      end
    end

    describe "GET 'edit/1'" do
      it 'should reject as not allowed' do
        get :edit, id: tutor_application_1.id
        expect_bounce_as_not_allowed
      end
    end

    describe "POST 'create'" do
      it 'should report OK for valid params' do
        post :create, tutor_application: valid_params
        expect(flash[:error]).to be_nil
        expect(flash[:success]).to eq(I18n.t('controllers.tutor_applications.create.flash.success'))
        expect(response.status).to eq(302)
        expect(response).to redirect_to(new_tutor_application_url)
        expect(assigns(('tutor_application').to_sym).class.name).to eq(('tutor_application').classify)
      end

      it 'should report error for invalid params' do
        post :create, tutor_application: {valid_params.keys.first => ''}
        expect_create_error_with_model('tutor_application')
      end
    end

    describe "PUT 'update/1'" do
      it 'should reject as not allowed' do
        put :update, id: tutor_application_1.id, tutor_application: valid_params
        expect_bounce_as_not_allowed
      end

      it 'should reject invalid params' do
        put :update, id: tutor_application_1.id, tutor_application: {valid_params.keys.first => ''}
        expect_bounce_as_not_allowed
      end
    end


    describe "DELETE 'destroy'" do
      it 'should reject as not allowed' do
        delete :destroy, id: tutor_application_1.id
        expect_bounce_as_not_allowed
      end

      it 'should be OK as no dependencies exist' do
        delete :destroy, id: tutor_application_2.id
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
      it 'should reject as not allowed' do
        get :index
        expect_bounce_as_not_allowed
      end
    end

    describe "GET 'show/1'" do
      it 'should reject as not allowed' do
        get :show, id: tutor_application_1.id
        expect_bounce_as_not_allowed
      end
    end

    describe "GET 'new'" do
      it 'should respond OK' do
        get :new
        expect_new_success_with_model('tutor_application')
      end
    end

    describe "GET 'edit/1'" do
      it 'should reject as not allowed' do
        get :edit, id: tutor_application_1.id
        expect_bounce_as_not_allowed
      end
    end

    describe "POST 'create'" do
      it 'should report OK for valid params' do
        post :create, tutor_application: valid_params
        expect(flash[:error]).to be_nil
        expect(flash[:success]).to eq(I18n.t('controllers.tutor_applications.create.flash.success'))
        expect(response.status).to eq(302)
        expect(response).to redirect_to(new_tutor_application_url)
        expect(assigns(('tutor_application').to_sym).class.name).to eq(('tutor_application').classify)
      end

      it 'should report error for invalid params' do
        post :create, tutor_application: {valid_params.keys.first => ''}
        expect_create_error_with_model('tutor_application')
      end
    end

    describe "PUT 'update/1'" do
      it 'should reject as not allowed' do
        put :update, id: tutor_application_1.id, tutor_application: valid_params
        expect_bounce_as_not_allowed
      end

      it 'should reject as not allowed' do
        put :update, id: tutor_application_1.id, tutor_application: {valid_params.keys.first => ''}
        expect_bounce_as_not_allowed
      end
    end


    describe "DELETE 'destroy'" do
      it 'should be ERROR as children exist' do
        delete :destroy, id: tutor_application_1.id
        expect_bounce_as_not_allowed
      end

      it 'should be OK as no dependencies exist' do
        delete :destroy, id: tutor_application_2.id
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
        expect_index_success_with_model('tutor_applications', 2)
      end
    end

    describe "GET 'show/1'" do
      it 'should see tutor_application_1' do
        get :show, id: tutor_application_1.id
        expect_show_success_with_model('tutor_application', tutor_application_1.id)
      end

      # optional - some other object
      it 'should see tutor_application_2' do
        get :show, id: tutor_application_2.id
        expect_show_success_with_model('tutor_application', tutor_application_2.id)
      end
    end

    describe "GET 'new'" do
      it 'should respond OK' do
        get :new
        expect_new_success_with_model('tutor_application')
      end
    end

    describe "GET 'edit/1'" do
      it 'should respond OK with tutor_application_1' do
        get :edit, id: tutor_application_1.id
        expect_edit_success_with_model('tutor_application', tutor_application_1.id)
      end

      # optional
      it 'should respond OK with tutor_application_2' do
        get :edit, id: tutor_application_2.id
        expect_edit_success_with_model('tutor_application', tutor_application_2.id)
      end
    end

    describe "POST 'create'" do
      it 'should report OK for valid params' do
        post :create, tutor_application: valid_params
        expect(flash[:error]).to be_nil
        expect(flash[:success]).to eq(I18n.t('controllers.tutor_applications.create.flash.success'))
        expect(response.status).to eq(302)
        expect(response).to redirect_to(new_tutor_application_url)
        expect(assigns(('tutor_application').to_sym).class.name).to eq(('tutor_application').classify)
      end

      it 'should report error for invalid params' do
        post :create, tutor_application: {valid_params.keys.first => ''}
        expect_create_error_with_model('tutor_application')
      end
    end

    describe "PUT 'update/1'" do
      it 'should respond OK to valid params for tutor_application_1' do
        put :update, id: tutor_application_1.id, tutor_application: valid_params
        expect_update_success_with_model('tutor_application', tutor_applications_url)
      end

      # optional
      it 'should respond OK to valid params for tutor_application_2' do
        put :update, id: tutor_application_2.id, tutor_application: valid_params
        expect_update_success_with_model('tutor_application', tutor_applications_url)
        expect(assigns(:tutor_application).id).to eq(tutor_application_2.id)
      end

      it 'should reject invalid params' do
        put :update, id: tutor_application_1.id, tutor_application: {valid_params.keys.first => ''}
        expect_update_error_with_model('tutor_application')
        expect(assigns(:tutor_application).id).to eq(tutor_application_1.id)
      end
    end


    describe "DELETE 'destroy'" do
      it 'should be OK as no dependencies exist' do
        delete :destroy, id: tutor_application_2.id
        expect_delete_success_with_model('tutor_application', tutor_applications_url)
      end
    end

  end

  context 'Logged in as a customer_support_manager_user: ' do

    before(:each) do
      activate_authlogic
      UserSession.create!(customer_support_manager_user)
    end

    describe "GET 'index'" do
      it 'should reject as not allowed' do
        get :index
        expect_bounce_as_not_allowed
      end
    end

    describe "GET 'show/1'" do
      it 'should reject as not allowed' do
        get :show, id: tutor_application_1.id
        expect_bounce_as_not_allowed
      end

      # optional - some other object
      it 'should reject as not allowed' do
        get :show, id: tutor_application_2.id
        expect_bounce_as_not_allowed
      end
    end

    describe "GET 'new'" do
      it 'should respond OK' do
        get :new
        expect_new_success_with_model('tutor_application')
      end
    end

    describe "POST 'create'" do
      it 'should report OK for valid params' do
        post :create, tutor_application: valid_params
        expect(flash[:error]).to be_nil
        expect(flash[:success]).to eq(I18n.t('controllers.tutor_applications.create.flash.success'))
        expect(response.status).to eq(302)
        expect(response).to redirect_to(new_tutor_application_url)
        expect(assigns(('tutor_application').to_sym).class.name).to eq(('tutor_application').classify)
      end

      it 'should report error for invalid params' do
        post :create, tutor_application: {valid_params.keys.first => ''}
        expect_create_error_with_model('tutor_application')
      end
    end

    describe "PUT 'update/1'" do
      it 'should reject as not allowed' do
        put :update, id: tutor_application_1.id, tutor_application: valid_params
        expect_bounce_as_not_allowed
      end

      it 'should reject as not allowed' do
        put :update, id: tutor_application_1.id, tutor_application: {valid_params.keys.first => ''}
        expect_bounce_as_not_allowed
      end
    end


    describe "DELETE 'destroy'" do
      it 'should be ERROR as children exist' do
        delete :destroy, id: tutor_application_1.id
        expect_bounce_as_not_allowed
      end

      it 'should be OK as no dependencies exist' do
        delete :destroy, id: tutor_application_2.id
        expect_bounce_as_not_allowed
      end
    end

  end

  context 'Logged in as a marketing_manager_user: ' do

    before(:each) do
      activate_authlogic
      UserSession.create!(marketing_manager_user)
    end

    describe "GET 'index'" do
      it 'should reject as not allowed' do
        get :index
        expect_bounce_as_not_allowed
      end
    end

    describe "GET 'show/1'" do
      it 'should reject as not allowed' do
        get :show, id: tutor_application_1.id
        expect_bounce_as_not_allowed
      end

      # optional - some other object
      it 'should reject as not allowed' do
        get :show, id: tutor_application_2.id
        expect_bounce_as_not_allowed
      end
    end

    describe "GET 'new'" do
      it 'should respond OK' do
        get :new
        expect_new_success_with_model('tutor_application')
      end
    end

    describe "POST 'create'" do
      it 'should report OK for valid params' do
        post :create, tutor_application: valid_params
        expect(flash[:error]).to be_nil
        expect(flash[:success]).to eq(I18n.t('controllers.tutor_applications.create.flash.success'))
        expect(response.status).to eq(302)
        expect(response).to redirect_to(new_tutor_application_url)
        expect(assigns(('tutor_application').to_sym).class.name).to eq(('tutor_application').classify)
      end

      it 'should report error for invalid params' do
        post :create, tutor_application: {valid_params.keys.first => ''}
        expect_create_error_with_model('tutor_application')
      end
    end

    describe "PUT 'update/1'" do
      it 'should reject as not allowed' do
        put :update, id: tutor_application_1.id, tutor_application: valid_params
        expect_bounce_as_not_allowed
      end

      it 'should reject as not allowed' do
        put :update, id: tutor_application_1.id, tutor_application: {valid_params.keys.first => ''}
        expect_bounce_as_not_allowed
      end
    end


    describe "DELETE 'destroy'" do
      it 'should be ERROR as children exist' do
        delete :destroy, id: tutor_application_1.id
        expect_bounce_as_not_allowed
      end

      it 'should be OK as no dependencies exist' do
        delete :destroy, id: tutor_application_2.id
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
        expect_index_success_with_model('tutor_applications', 2)
      end
    end

    describe "GET 'show/1'" do
      it 'should see tutor_application_1' do
        get :show, id: tutor_application_1.id
        expect_show_success_with_model('tutor_application', tutor_application_1.id)
      end

      # optional - some other object
      it 'should see tutor_application_2' do
        get :show, id: tutor_application_2.id
        expect_show_success_with_model('tutor_application', tutor_application_2.id)
      end
    end

    describe "GET 'new'" do
      it 'should respond OK' do
        get :new
        expect_new_success_with_model('tutor_application')
      end
    end

    describe "GET 'edit/1'" do
      it 'should respond OK with tutor_application_1' do
        get :edit, id: tutor_application_1.id
        expect_edit_success_with_model('tutor_application', tutor_application_1.id)
      end

      # optional
      it 'should respond OK with tutor_application_2' do
        get :edit, id: tutor_application_2.id
        expect_edit_success_with_model('tutor_application', tutor_application_2.id)
      end
    end

    describe "POST 'create'" do
      it 'should report OK for valid params' do
        post :create, tutor_application: valid_params
        expect(flash[:error]).to be_nil
        expect(flash[:success]).to eq(I18n.t('controllers.tutor_applications.create.flash.success'))
        expect(response.status).to eq(302)
        expect(response).to redirect_to(new_tutor_application_url)
        expect(assigns(('tutor_application').to_sym).class.name).to eq(('tutor_application').classify)
      end

      it 'should report error for invalid params' do
        post :create, tutor_application: {valid_params.keys.first => ''}
        expect_create_error_with_model('tutor_application')
      end
    end

    describe "PUT 'update/1'" do
      it 'should respond OK to valid params for tutor_application_1' do
        put :update, id: tutor_application_1.id, tutor_application: valid_params
        expect_update_success_with_model('tutor_application', tutor_applications_url)
      end

      # optional
      it 'should respond OK to valid params for tutor_application_2' do
        put :update, id: tutor_application_2.id, tutor_application: valid_params
        expect_update_success_with_model('tutor_application', tutor_applications_url)
        expect(assigns(:tutor_application).id).to eq(tutor_application_2.id)
      end

      it 'should reject invalid params' do
        put :update, id: tutor_application_1.id, tutor_application: {valid_params.keys.first => ''}
        expect_update_error_with_model('tutor_application')
        expect(assigns(:tutor_application).id).to eq(tutor_application_1.id)
      end
    end


    describe "DELETE 'destroy'" do
      it 'should be OK as no dependencies exist' do
        delete :destroy, id: tutor_application_2.id
        expect_delete_success_with_model('tutor_application', tutor_applications_url)
      end
    end

  end

end
