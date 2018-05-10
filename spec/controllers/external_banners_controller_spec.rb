# == Schema Information
#
# Table name: external_banners
#
#  id                 :integer          not null, primary key
#  name               :string
#  sorting_order      :integer
#  active             :boolean          default(FALSE)
#  background_colour  :string
#  text_content       :text
#  created_at         :datetime         not null
#  updated_at         :datetime         not null
#  user_sessions      :boolean          default(FALSE)
#  library            :boolean          default(FALSE)
#  subscription_plans :boolean          default(FALSE)
#  footer_pages       :boolean          default(FALSE)
#  student_sign_ups   :boolean          default(FALSE)
#  home_page_id       :integer
#  content_page_id    :integer
#

require 'rails_helper'
require 'support/users_and_groups_setup'

describe ExternalBannersController, type: :controller do

  include_context 'users_and_groups_setup'

  # todo: Try to create children for external_banner_1
  let!(:external_banner_1) { FactoryBot.create(:external_banner) }
  let!(:external_banner_2) { FactoryBot.create(:external_banner) }
  let!(:valid_params) { FactoryBot.attributes_for(:external_banner) }

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

    describe "POST 'reorder'" do
      it 'should be OK with valid_array' do
        post :create, array_of_ids: [1,2]
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
        expect_index_success_with_model('external_banners', 2)
      end
    end

    describe "GET 'show/1'" do
      it 'should see external_banner_1' do
        get :show, id: external_banner_1.id
        expect_show_success_with_model('external_banner', external_banner_1.id)
      end

      # optional - some other object
      it 'should see external_banner_2' do
        get :show, id: external_banner_2.id
        expect_show_success_with_model('external_banner', external_banner_2.id)
      end
    end

    describe "GET 'new'" do
      it 'should respond OK' do
        get :new
        expect_new_success_with_model('external_banner')
      end
    end

    describe "GET 'edit/1'" do
      it 'should respond OK with external_banner_1' do
        get :edit, id: external_banner_1.id
        expect_edit_success_with_model('external_banner', external_banner_1.id)
      end

      # optional
      it 'should respond OK with external_banner_2' do
        get :edit, id: external_banner_2.id
        expect_edit_success_with_model('external_banner', external_banner_2.id)
      end
    end

    describe "POST 'create'" do
      it 'should report OK for valid params' do
        post :create, external_banner: valid_params
        expect_create_success_with_model('external_banner', external_banners_url)
      end

      it 'should report error for invalid params' do
        post :create, external_banner: {valid_params.keys.first => ''}
        expect_create_error_with_model('external_banner')
      end
    end

    describe "PUT 'update/1'" do
      it 'should respond OK to valid params for external_banner_1' do
        put :update, id: external_banner_1.id, external_banner: valid_params
        expect_update_success_with_model('external_banner', external_banners_url)
      end

      # optional
      it 'should respond OK to valid params for external_banner_2' do
        put :update, id: external_banner_2.id, external_banner: valid_params
        expect_update_success_with_model('external_banner', external_banners_url)
        expect(assigns(:external_banner).id).to eq(external_banner_2.id)
      end

      it 'should reject invalid params' do
        put :update, id: external_banner_1.id, external_banner: {valid_params.keys.first => ''}
        expect_update_error_with_model('external_banner')
        expect(assigns(:external_banner).id).to eq(external_banner_1.id)
      end
    end

    describe "POST 'reorder'" do
      it 'should be OK with valid_array' do
        post :reorder, array_of_ids: [external_banner_2.id, external_banner_1.id]
        expect_reorder_success
      end
    end

    describe "DELETE 'destroy'" do
      it 'should be ERROR as children exist' do
        delete :destroy, id: external_banner_1.id
        expect_delete_error_with_model('external_banner', external_banners_url)
      end

      it 'should be OK as no dependencies exist' do
        delete :destroy, id: external_banner_2.id
        expect_delete_success_with_model('external_banner', external_banners_url)
      end
    end

  end

  context 'Logged in as a complimentary_user: ' do

    before(:each) do
      activate_authlogic
      UserSession.create!(complimentary_user)
    end

    describe "GET 'index'" do
      it 'should respond OK' do
        get :index
        expect_index_success_with_model('external_banners', 2)
      end
    end

    describe "GET 'show/1'" do
      it 'should see external_banner_1' do
        get :show, id: external_banner_1.id
        expect_show_success_with_model('external_banner', external_banner_1.id)
      end

      # optional - some other object
      it 'should see external_banner_2' do
        get :show, id: external_banner_2.id
        expect_show_success_with_model('external_banner', external_banner_2.id)
      end
    end

    describe "GET 'new'" do
      it 'should respond OK' do
        get :new
        expect_new_success_with_model('external_banner')
      end
    end

    describe "GET 'edit/1'" do
      it 'should respond OK with external_banner_1' do
        get :edit, id: external_banner_1.id
        expect_edit_success_with_model('external_banner', external_banner_1.id)
      end

      # optional
      it 'should respond OK with external_banner_2' do
        get :edit, id: external_banner_2.id
        expect_edit_success_with_model('external_banner', external_banner_2.id)
      end
    end

    describe "POST 'create'" do
      it 'should report OK for valid params' do
        post :create, external_banner: valid_params
        expect_create_success_with_model('external_banner', external_banners_url)
      end

      it 'should report error for invalid params' do
        post :create, external_banner: {valid_params.keys.first => ''}
        expect_create_error_with_model('external_banner')
      end
    end

    describe "PUT 'update/1'" do
      it 'should respond OK to valid params for external_banner_1' do
        put :update, id: external_banner_1.id, external_banner: valid_params
        expect_update_success_with_model('external_banner', external_banners_url)
      end

      # optional
      it 'should respond OK to valid params for external_banner_2' do
        put :update, id: external_banner_2.id, external_banner: valid_params
        expect_update_success_with_model('external_banner', external_banners_url)
        expect(assigns(:external_banner).id).to eq(external_banner_2.id)
      end

      it 'should reject invalid params' do
        put :update, id: external_banner_1.id, external_banner: {valid_params.keys.first => ''}
        expect_update_error_with_model('external_banner')
        expect(assigns(:external_banner).id).to eq(external_banner_1.id)
      end
    end

    describe "POST 'reorder'" do
      it 'should be OK with valid_array' do
        post :reorder, array_of_ids: [external_banner_2.id, external_banner_1.id]
        expect_reorder_success
      end
    end

    describe "DELETE 'destroy'" do
      it 'should be ERROR as children exist' do
        delete :destroy, id: external_banner_1.id
        expect_delete_error_with_model('external_banner', external_banners_url)
      end

      it 'should be OK as no dependencies exist' do
        delete :destroy, id: external_banner_2.id
        expect_delete_success_with_model('external_banner', external_banners_url)
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
        expect_index_success_with_model('external_banners', 2)
      end
    end

    describe "GET 'show/1'" do
      it 'should see external_banner_1' do
        get :show, id: external_banner_1.id
        expect_show_success_with_model('external_banner', external_banner_1.id)
      end

      # optional - some other object
      it 'should see external_banner_2' do
        get :show, id: external_banner_2.id
        expect_show_success_with_model('external_banner', external_banner_2.id)
      end
    end

    describe "GET 'new'" do
      it 'should respond OK' do
        get :new
        expect_new_success_with_model('external_banner')
      end
    end

    describe "GET 'edit/1'" do
      it 'should respond OK with external_banner_1' do
        get :edit, id: external_banner_1.id
        expect_edit_success_with_model('external_banner', external_banner_1.id)
      end

      # optional
      it 'should respond OK with external_banner_2' do
        get :edit, id: external_banner_2.id
        expect_edit_success_with_model('external_banner', external_banner_2.id)
      end
    end

    describe "POST 'create'" do
      it 'should report OK for valid params' do
        post :create, external_banner: valid_params
        expect_create_success_with_model('external_banner', external_banners_url)
      end

      it 'should report error for invalid params' do
        post :create, external_banner: {valid_params.keys.first => ''}
        expect_create_error_with_model('external_banner')
      end
    end

    describe "PUT 'update/1'" do
      it 'should respond OK to valid params for external_banner_1' do
        put :update, id: external_banner_1.id, external_banner: valid_params
        expect_update_success_with_model('external_banner', external_banners_url)
      end

      # optional
      it 'should respond OK to valid params for external_banner_2' do
        put :update, id: external_banner_2.id, external_banner: valid_params
        expect_update_success_with_model('external_banner', external_banners_url)
        expect(assigns(:external_banner).id).to eq(external_banner_2.id)
      end

      it 'should reject invalid params' do
        put :update, id: external_banner_1.id, external_banner: {valid_params.keys.first => ''}
        expect_update_error_with_model('external_banner')
        expect(assigns(:external_banner).id).to eq(external_banner_1.id)
      end
    end

    describe "POST 'reorder'" do
      it 'should be OK with valid_array' do
        post :reorder, array_of_ids: [external_banner_2.id, external_banner_1.id]
        expect_reorder_success
      end
    end

    describe "DELETE 'destroy'" do
      it 'should be ERROR as children exist' do
        delete :destroy, id: external_banner_1.id
        expect_delete_error_with_model('external_banner', external_banners_url)
      end

      it 'should be OK as no dependencies exist' do
        delete :destroy, id: external_banner_2.id
        expect_delete_success_with_model('external_banner', external_banners_url)
      end
    end

  end

  context 'Logged in as a comp_user_user: ' do

    before(:each) do
      activate_authlogic
      UserSession.create!(comp_user_user)
    end

    describe "GET 'index'" do
      it 'should respond OK' do
        get :index
        expect_index_success_with_model('external_banners', 2)
      end
    end

    describe "GET 'show/1'" do
      it 'should see external_banner_1' do
        get :show, id: external_banner_1.id
        expect_show_success_with_model('external_banner', external_banner_1.id)
      end

      # optional - some other object
      it 'should see external_banner_2' do
        get :show, id: external_banner_2.id
        expect_show_success_with_model('external_banner', external_banner_2.id)
      end
    end

    describe "GET 'new'" do
      it 'should respond OK' do
        get :new
        expect_new_success_with_model('external_banner')
      end
    end

    describe "GET 'edit/1'" do
      it 'should respond OK with external_banner_1' do
        get :edit, id: external_banner_1.id
        expect_edit_success_with_model('external_banner', external_banner_1.id)
      end

      # optional
      it 'should respond OK with external_banner_2' do
        get :edit, id: external_banner_2.id
        expect_edit_success_with_model('external_banner', external_banner_2.id)
      end
    end

    describe "POST 'create'" do
      it 'should report OK for valid params' do
        post :create, external_banner: valid_params
        expect_create_success_with_model('external_banner', external_banners_url)
      end

      it 'should report error for invalid params' do
        post :create, external_banner: {valid_params.keys.first => ''}
        expect_create_error_with_model('external_banner')
      end
    end

    describe "PUT 'update/1'" do
      it 'should respond OK to valid params for external_banner_1' do
        put :update, id: external_banner_1.id, external_banner: valid_params
        expect_update_success_with_model('external_banner', external_banners_url)
      end

      # optional
      it 'should respond OK to valid params for external_banner_2' do
        put :update, id: external_banner_2.id, external_banner: valid_params
        expect_update_success_with_model('external_banner', external_banners_url)
        expect(assigns(:external_banner).id).to eq(external_banner_2.id)
      end

      it 'should reject invalid params' do
        put :update, id: external_banner_1.id, external_banner: {valid_params.keys.first => ''}
        expect_update_error_with_model('external_banner')
        expect(assigns(:external_banner).id).to eq(external_banner_1.id)
      end
    end

    describe "POST 'reorder'" do
      it 'should be OK with valid_array' do
        post :reorder, array_of_ids: [external_banner_2.id, external_banner_1.id]
        expect_reorder_success
      end
    end

    describe "DELETE 'destroy'" do
      it 'should be ERROR as children exist' do
        delete :destroy, id: external_banner_1.id
        expect_delete_error_with_model('external_banner', external_banners_url)
      end

      it 'should be OK as no dependencies exist' do
        delete :destroy, id: external_banner_2.id
        expect_delete_success_with_model('external_banner', external_banners_url)
      end
    end

  end

  context 'Logged in as a marketing_manager_user_user: ' do

    before(:each) do
      activate_authlogic
      UserSession.create!(marketing_manager_user_user)
    end

    describe "GET 'index'" do
      it 'should respond OK' do
        get :index
        expect_index_success_with_model('external_banners', 2)
      end
    end

    describe "GET 'show/1'" do
      it 'should see external_banner_1' do
        get :show, id: external_banner_1.id
        expect_show_success_with_model('external_banner', external_banner_1.id)
      end

      # optional - some other object
      it 'should see external_banner_2' do
        get :show, id: external_banner_2.id
        expect_show_success_with_model('external_banner', external_banner_2.id)
      end
    end

    describe "GET 'new'" do
      it 'should respond OK' do
        get :new
        expect_new_success_with_model('external_banner')
      end
    end

    describe "GET 'edit/1'" do
      it 'should respond OK with external_banner_1' do
        get :edit, id: external_banner_1.id
        expect_edit_success_with_model('external_banner', external_banner_1.id)
      end

      # optional
      it 'should respond OK with external_banner_2' do
        get :edit, id: external_banner_2.id
        expect_edit_success_with_model('external_banner', external_banner_2.id)
      end
    end

    describe "POST 'create'" do
      it 'should report OK for valid params' do
        post :create, external_banner: valid_params
        expect_create_success_with_model('external_banner', external_banners_url)
      end

      it 'should report error for invalid params' do
        post :create, external_banner: {valid_params.keys.first => ''}
        expect_create_error_with_model('external_banner')
      end
    end

    describe "PUT 'update/1'" do
      it 'should respond OK to valid params for external_banner_1' do
        put :update, id: external_banner_1.id, external_banner: valid_params
        expect_update_success_with_model('external_banner', external_banners_url)
      end

      # optional
      it 'should respond OK to valid params for external_banner_2' do
        put :update, id: external_banner_2.id, external_banner: valid_params
        expect_update_success_with_model('external_banner', external_banners_url)
        expect(assigns(:external_banner).id).to eq(external_banner_2.id)
      end

      it 'should reject invalid params' do
        put :update, id: external_banner_1.id, external_banner: {valid_params.keys.first => ''}
        expect_update_error_with_model('external_banner')
        expect(assigns(:external_banner).id).to eq(external_banner_1.id)
      end
    end

    describe "POST 'reorder'" do
      it 'should be OK with valid_array' do
        post :reorder, array_of_ids: [external_banner_2.id, external_banner_1.id]
        expect_reorder_success
      end
    end

    describe "DELETE 'destroy'" do
      it 'should be ERROR as children exist' do
        delete :destroy, id: external_banner_1.id
        expect_delete_error_with_model('external_banner', external_banners_url)
      end

      it 'should be OK as no dependencies exist' do
        delete :destroy, id: external_banner_2.id
        expect_delete_success_with_model('external_banner', external_banners_url)
      end
    end

  end

  context 'Logged in as a customer_support_manager_user_user: ' do

    before(:each) do
      activate_authlogic
      UserSession.create!(customer_support_manager_user_user)
    end

    describe "GET 'index'" do
      it 'should respond OK' do
        get :index
        expect_index_success_with_model('external_banners', 2)
      end
    end

    describe "GET 'show/1'" do
      it 'should see external_banner_1' do
        get :show, id: external_banner_1.id
        expect_show_success_with_model('external_banner', external_banner_1.id)
      end

      # optional - some other object
      it 'should see external_banner_2' do
        get :show, id: external_banner_2.id
        expect_show_success_with_model('external_banner', external_banner_2.id)
      end
    end

    describe "GET 'new'" do
      it 'should respond OK' do
        get :new
        expect_new_success_with_model('external_banner')
      end
    end

    describe "GET 'edit/1'" do
      it 'should respond OK with external_banner_1' do
        get :edit, id: external_banner_1.id
        expect_edit_success_with_model('external_banner', external_banner_1.id)
      end

      # optional
      it 'should respond OK with external_banner_2' do
        get :edit, id: external_banner_2.id
        expect_edit_success_with_model('external_banner', external_banner_2.id)
      end
    end

    describe "POST 'create'" do
      it 'should report OK for valid params' do
        post :create, external_banner: valid_params
        expect_create_success_with_model('external_banner', external_banners_url)
      end

      it 'should report error for invalid params' do
        post :create, external_banner: {valid_params.keys.first => ''}
        expect_create_error_with_model('external_banner')
      end
    end

    describe "PUT 'update/1'" do
      it 'should respond OK to valid params for external_banner_1' do
        put :update, id: external_banner_1.id, external_banner: valid_params
        expect_update_success_with_model('external_banner', external_banners_url)
      end

      # optional
      it 'should respond OK to valid params for external_banner_2' do
        put :update, id: external_banner_2.id, external_banner: valid_params
        expect_update_success_with_model('external_banner', external_banners_url)
        expect(assigns(:external_banner).id).to eq(external_banner_2.id)
      end

      it 'should reject invalid params' do
        put :update, id: external_banner_1.id, external_banner: {valid_params.keys.first => ''}
        expect_update_error_with_model('external_banner')
        expect(assigns(:external_banner).id).to eq(external_banner_1.id)
      end
    end

    describe "POST 'reorder'" do
      it 'should be OK with valid_array' do
        post :reorder, array_of_ids: [external_banner_2.id, external_banner_1.id]
        expect_reorder_success
      end
    end

    describe "DELETE 'destroy'" do
      it 'should be ERROR as children exist' do
        delete :destroy, id: external_banner_1.id
        expect_delete_error_with_model('external_banner', external_banners_url)
      end

      it 'should be OK as no dependencies exist' do
        delete :destroy, id: external_banner_2.id
        expect_delete_success_with_model('external_banner', external_banners_url)
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
        expect_index_success_with_model('external_banners', 2)
      end
    end

    describe "GET 'show/1'" do
      it 'should see external_banner_1' do
        get :show, id: external_banner_1.id
        expect_show_success_with_model('external_banner', external_banner_1.id)
      end

      # optional - some other object
      it 'should see external_banner_2' do
        get :show, id: external_banner_2.id
        expect_show_success_with_model('external_banner', external_banner_2.id)
      end
    end

    describe "GET 'new'" do
      it 'should respond OK' do
        get :new
        expect_new_success_with_model('external_banner')
      end
    end

    describe "GET 'edit/1'" do
      it 'should respond OK with external_banner_1' do
        get :edit, id: external_banner_1.id
        expect_edit_success_with_model('external_banner', external_banner_1.id)
      end

      # optional
      it 'should respond OK with external_banner_2' do
        get :edit, id: external_banner_2.id
        expect_edit_success_with_model('external_banner', external_banner_2.id)
      end
    end

    describe "POST 'create'" do
      it 'should report OK for valid params' do
        post :create, external_banner: valid_params
        expect_create_success_with_model('external_banner', external_banners_url)
      end

      it 'should report error for invalid params' do
        post :create, external_banner: {valid_params.keys.first => ''}
        expect_create_error_with_model('external_banner')
      end
    end

    describe "PUT 'update/1'" do
      it 'should respond OK to valid params for external_banner_1' do
        put :update, id: external_banner_1.id, external_banner: valid_params
        expect_update_success_with_model('external_banner', external_banners_url)
      end

      # optional
      it 'should respond OK to valid params for external_banner_2' do
        put :update, id: external_banner_2.id, external_banner: valid_params
        expect_update_success_with_model('external_banner', external_banners_url)
        expect(assigns(:external_banner).id).to eq(external_banner_2.id)
      end

      it 'should reject invalid params' do
        put :update, id: external_banner_1.id, external_banner: {valid_params.keys.first => ''}
        expect_update_error_with_model('external_banner')
        expect(assigns(:external_banner).id).to eq(external_banner_1.id)
      end
    end

    describe "POST 'reorder'" do
      it 'should be OK with valid_array' do
        post :reorder, array_of_ids: [external_banner_2.id, external_banner_1.id]
        expect_reorder_success
      end
    end

    describe "DELETE 'destroy'" do
      it 'should be ERROR as children exist' do
        delete :destroy, id: external_banner_1.id
        expect_delete_error_with_model('external_banner', external_banners_url)
      end

      it 'should be OK as no dependencies exist' do
        delete :destroy, id: external_banner_2.id
        expect_delete_success_with_model('external_banner', external_banners_url)
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
        expect_index_success_with_model('external_banners', 2)
      end
    end

    describe "GET 'show/1'" do
      it 'should see external_banner_1' do
        get :show, id: external_banner_1.id
        expect_show_success_with_model('external_banner', external_banner_1.id)
      end

      # optional - some other object
      it 'should see external_banner_2' do
        get :show, id: external_banner_2.id
        expect_show_success_with_model('external_banner', external_banner_2.id)
      end
    end

    describe "GET 'new'" do
      it 'should respond OK' do
        get :new
        expect_new_success_with_model('external_banner')
      end
    end

    describe "GET 'edit/1'" do
      it 'should respond OK with external_banner_1' do
        get :edit, id: external_banner_1.id
        expect_edit_success_with_model('external_banner', external_banner_1.id)
      end

      # optional
      it 'should respond OK with external_banner_2' do
        get :edit, id: external_banner_2.id
        expect_edit_success_with_model('external_banner', external_banner_2.id)
      end
    end

    describe "POST 'create'" do
      it 'should report OK for valid params' do
        post :create, external_banner: valid_params
        expect_create_success_with_model('external_banner', external_banners_url)
      end

      it 'should report error for invalid params' do
        post :create, external_banner: {valid_params.keys.first => ''}
        expect_create_error_with_model('external_banner')
      end
    end

    describe "PUT 'update/1'" do
      it 'should respond OK to valid params for external_banner_1' do
        put :update, id: external_banner_1.id, external_banner: valid_params
        expect_update_success_with_model('external_banner', external_banners_url)
      end

      # optional
      it 'should respond OK to valid params for external_banner_2' do
        put :update, id: external_banner_2.id, external_banner: valid_params
        expect_update_success_with_model('external_banner', external_banners_url)
        expect(assigns(:external_banner).id).to eq(external_banner_2.id)
      end

      it 'should reject invalid params' do
        put :update, id: external_banner_1.id, external_banner: {valid_params.keys.first => ''}
        expect_update_error_with_model('external_banner')
        expect(assigns(:external_banner).id).to eq(external_banner_1.id)
      end
    end

    describe "POST 'reorder'" do
      it 'should be OK with valid_array' do
        post :reorder, array_of_ids: [external_banner_2.id, external_banner_1.id]
        expect_reorder_success
      end
    end

    describe "DELETE 'destroy'" do
      it 'should be ERROR as children exist' do
        delete :destroy, id: external_banner_1.id
        expect_delete_error_with_model('external_banner', external_banners_url)
      end

      it 'should be OK as no dependencies exist' do
        delete :destroy, id: external_banner_2.id
        expect_delete_success_with_model('external_banner', external_banners_url)
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
        expect_index_success_with_model('external_banners', 2)
      end
    end

    describe "GET 'show/1'" do
      it 'should see external_banner_1' do
        get :show, id: external_banner_1.id
        expect_show_success_with_model('external_banner', external_banner_1.id)
      end

      # optional - some other object
      it 'should see external_banner_2' do
        get :show, id: external_banner_2.id
        expect_show_success_with_model('external_banner', external_banner_2.id)
      end
    end

    describe "GET 'new'" do
      it 'should respond OK' do
        get :new
        expect_new_success_with_model('external_banner')
      end
    end

    describe "GET 'edit/1'" do
      it 'should respond OK with external_banner_1' do
        get :edit, id: external_banner_1.id
        expect_edit_success_with_model('external_banner', external_banner_1.id)
      end

      # optional
      it 'should respond OK with external_banner_2' do
        get :edit, id: external_banner_2.id
        expect_edit_success_with_model('external_banner', external_banner_2.id)
      end
    end

    describe "POST 'create'" do
      it 'should report OK for valid params' do
        post :create, external_banner: valid_params
        expect_create_success_with_model('external_banner', external_banners_url)
      end

      it 'should report error for invalid params' do
        post :create, external_banner: {valid_params.keys.first => ''}
        expect_create_error_with_model('external_banner')
      end
    end

    describe "PUT 'update/1'" do
      it 'should respond OK to valid params for external_banner_1' do
        put :update, id: external_banner_1.id, external_banner: valid_params
        expect_update_success_with_model('external_banner', external_banners_url)
      end

      # optional
      it 'should respond OK to valid params for external_banner_2' do
        put :update, id: external_banner_2.id, external_banner: valid_params
        expect_update_success_with_model('external_banner', external_banners_url)
        expect(assigns(:external_banner).id).to eq(external_banner_2.id)
      end

      it 'should reject invalid params' do
        put :update, id: external_banner_1.id, external_banner: {valid_params.keys.first => ''}
        expect_update_error_with_model('external_banner')
        expect(assigns(:external_banner).id).to eq(external_banner_1.id)
      end
    end

    describe "POST 'reorder'" do
      it 'should be OK with valid_array' do
        post :reorder, array_of_ids: [external_banner_2.id, external_banner_1.id]
        expect_reorder_success
      end
    end

    describe "DELETE 'destroy'" do
      it 'should be ERROR as children exist' do
        delete :destroy, id: external_banner_1.id
        expect_delete_error_with_model('external_banner', external_banners_url)
      end

      it 'should be OK as no dependencies exist' do
        delete :destroy, id: external_banner_2.id
        expect_delete_success_with_model('external_banner', external_banners_url)
      end
    end

  end

end
