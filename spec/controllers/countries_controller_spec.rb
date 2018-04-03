# == Schema Information
#
# Table name: countries
#
#  id            :integer          not null, primary key
#  name          :string
#  iso_code      :string
#  country_tld   :string
#  sorting_order :integer
#  in_the_eu     :boolean          default(FALSE), not null
#  currency_id   :integer
#  created_at    :datetime
#  updated_at    :datetime
#  continent     :string
#

require 'rails_helper'
require 'support/users_and_groups_setup'

describe CountriesController, type: :controller do

  include_context 'users_and_groups_setup'

  let!(:gbp) { FactoryBot.create(:gbp) }
  let!(:eur) { FactoryBot.create(:euro) }
  let!(:usd) { FactoryBot.create(:usd) }

  let!(:uk) { FactoryBot.create(:uk, currency_id: gbp.id) }
  let!(:ireland) { FactoryBot.create(:ireland, currency_id: eur.id) }
  let!(:usa) { FactoryBot.create(:usa, currency_id: usd.id) }

  let!(:valid_params) { FactoryBot.attributes_for(:fr) }

  context 'Not logged in: ' do

    describe 'GET index' do
      it 'should redirect to sign_in' do
        get :index
        expect_bounce_as_not_signed_in
      end
    end

    describe 'GET show' do
      it 'should redirect to sign_in' do
        get :show, id: 1
        expect_bounce_as_not_signed_in
      end
    end

    describe 'GET new' do
      it 'should redirect to sign_in' do
        get :new
        expect_bounce_as_not_signed_in
      end
    end

    describe 'GET edit' do
      it 'should redirect to sign_in' do
        get :edit, id: 1
        expect_bounce_as_not_signed_in
      end
    end

    describe 'POST create' do
      it 'should redirect to sign_in' do
        post :create, country: valid_params
        expect_bounce_as_not_signed_in
      end
    end

    describe 'PUT update' do
      it 'should redirect to sign_in' do
        put :update, id: 1, country: valid_params
        expect_bounce_as_not_signed_in
      end
    end

    describe 'POST reorder' do
      it 'should redirect to sign_in' do
        post :create, array_of_ids: [1,2]
        expect_bounce_as_not_signed_in
      end
    end

    describe 'DELETE destroy' do
      it 'should redirect to sign_in' do
        delete :destroy, id: 1
        expect_bounce_as_not_signed_in
      end
    end

  end

  context 'Logged in as a valid_trial_student: ' do

    before(:each) do
      activate_authlogic
      UserSession.create!(valid_trial_student)
    end

    describe 'GET index' do
      it 'should respond ERROR not permitted' do
        get :index
        expect_bounce_as_not_allowed
      end
    end

    describe 'GET show' do
      it 'should respond ERROR not permitted' do
        get :show, id: 1
        expect_bounce_as_not_allowed
      end
    end

    describe 'GET new' do
      it 'should respond ERROR not permitted' do
        get :new
        expect_bounce_as_not_allowed
      end
    end

    describe 'GET edit' do
      it 'should respond ERROR not permitted' do
        get :edit, id: 1
        expect_bounce_as_not_allowed
      end
    end

    describe 'POST create' do
      it 'should respond ERROR not permitted' do
        post :create, country: valid_params
        expect_bounce_as_not_allowed
      end
    end

    describe 'PUT update' do
      it 'should respond ERROR not permitted' do
        put :update, id: 1, country: valid_params
        expect_bounce_as_not_allowed
      end
    end

    describe 'POST reorder' do
      it 'should respond ERROR not permitted' do
        post :create, array_of_ids: [1,2]
        expect_bounce_as_not_allowed
      end
    end

    describe 'DELETE destroy' do
      it 'should respond ERROR not permitted' do
        delete :destroy, id: 1
        expect_bounce_as_not_allowed
      end
    end

  end

  context 'Logged in as a invalid_trial_student: ' do

    before(:each) do
      activate_authlogic
      UserSession.create!(invalid_trial_student)
    end

    describe 'GET index' do
      it 'should respond ERROR not permitted' do
        get :index
        expect_bounce_as_not_allowed
      end
    end

    describe 'GET show' do
      it 'should respond ERROR not permitted' do
        get :show, id: 1
        expect_bounce_as_not_allowed
      end
    end

    describe 'GET new' do
      it 'should respond ERROR not permitted' do
        get :new
        expect_bounce_as_not_allowed
      end
    end

    describe 'GET edit' do
      it 'should respond ERROR not permitted' do
        get :edit, id: 1
        expect_bounce_as_not_allowed
      end
    end

    describe 'POST create' do
      it 'should respond ERROR not permitted' do
        post :create, country: valid_params
        expect_bounce_as_not_allowed
      end
    end

    describe 'PUT update' do
      it 'should respond ERROR not permitted' do
        put :update, id: 1, country: valid_params
        expect_bounce_as_not_allowed
      end
    end

    describe 'POST reorder' do
      it 'should respond ERROR not permitted' do
        post :create, array_of_ids: [1,2]
        expect_bounce_as_not_allowed
      end
    end

    describe 'DELETE destroy' do
      it 'should respond ERROR not permitted' do
        delete :destroy, id: 1
        expect_bounce_as_not_allowed
      end
    end

  end

  context 'Logged in as a valid_subscription_student: ' do

    before(:each) do
      activate_authlogic
      UserSession.create!(valid_subscription_student)
    end

    describe 'GET index' do
      it 'should respond ERROR not permitted' do
        get :index
        expect_bounce_as_not_allowed
      end
    end

    describe 'GET show' do
      it 'should respond ERROR not permitted' do
        get :show, id: 1
        expect_bounce_as_not_allowed
      end
    end

    describe 'GET new' do
      it 'should respond ERROR not permitted' do
        get :new
        expect_bounce_as_not_allowed
      end
    end

    describe 'GET edit' do
      it 'should respond ERROR not permitted' do
        get :edit, id: 1
        expect_bounce_as_not_allowed
      end
    end

    describe 'POST create' do
      it 'should respond ERROR not permitted' do
        post :create, country: valid_params
        expect_bounce_as_not_allowed
      end
    end

    describe 'PUT update' do
      it 'should respond ERROR not permitted' do
        put :update, id: 1, country: valid_params
        expect_bounce_as_not_allowed
      end
    end

    describe 'POST reorder' do
      it 'should respond ERROR not permitted' do
        post :create, array_of_ids: [1,2]
        expect_bounce_as_not_allowed
      end
    end

    describe 'DELETE destroy' do
      it 'should respond ERROR not permitted' do
        delete :destroy, id: 1
        expect_bounce_as_not_allowed
      end
    end

  end

  context 'Logged in as a invalid_subscription_student: ' do

    before(:each) do
      activate_authlogic
      UserSession.create!(invalid_subscription_student)
    end

    describe 'GET index' do
      it 'should respond ERROR not permitted' do
        get :index
        expect_bounce_as_not_allowed
      end
    end

    describe 'GET show' do
      it 'should respond ERROR not permitted' do
        get :show, id: 1
        expect_bounce_as_not_allowed
      end
    end

    describe 'GET new' do
      it 'should respond ERROR not permitted' do
        get :new
        expect_bounce_as_not_allowed
      end
    end

    describe 'GET edit' do
      it 'should respond ERROR not permitted' do
        get :edit, id: 1
        expect_bounce_as_not_allowed
      end
    end

    describe 'POST create' do
      it 'should respond ERROR not permitted' do
        post :create, country: valid_params
        expect_bounce_as_not_allowed
      end
    end

    describe 'PUT update' do
      it 'should respond ERROR not permitted' do
        put :update, id: 1, country: valid_params
        expect_bounce_as_not_allowed
      end
    end

    describe 'POST reorder' do
      it 'should respond ERROR not permitted' do
        post :create, array_of_ids: [1,2]
        expect_bounce_as_not_allowed
      end
    end

    describe 'DELETE destroy' do
      it 'should respond ERROR not permitted' do
        delete :destroy, id: 1
        expect_bounce_as_not_allowed
      end
    end

  end

  context 'Logged in as a complimentary_user: ' do

    before(:each) do
      activate_authlogic
      UserSession.create!(comp_user)
    end

    describe 'GET index' do
      it 'should respond ERROR not permitted' do
        get :index
        expect_bounce_as_not_allowed
      end
    end

    describe 'GET show' do
      it 'should respond ERROR not permitted' do
        get :show, id: 1
        expect_bounce_as_not_allowed
      end
    end

    describe 'GET new' do
      it 'should respond ERROR not permitted' do
        get :new
        expect_bounce_as_not_allowed
      end
    end

    describe 'GET edit' do
      it 'should respond ERROR not permitted' do
        get :edit, id: 1
        expect_bounce_as_not_allowed
      end
    end

    describe 'POST create' do
      it 'should respond ERROR not permitted' do
        post :create, country: valid_params
        expect_bounce_as_not_allowed
      end
    end

    describe 'PUT update' do
      it 'should respond ERROR not permitted' do
        put :update, id: 1, country: valid_params
        expect_bounce_as_not_allowed
      end
    end

    describe 'POST reorder' do
      it 'should respond ERROR not permitted' do
        post :create, array_of_ids: [1,2]
        expect_bounce_as_not_allowed
      end
    end

    describe 'DELETE destroy' do
      it 'should respond ERROR not permitted' do
        delete :destroy, id: 1
        expect_bounce_as_not_allowed
      end
    end

  end

  context 'Logged in as a tutor_user: ' do

    before(:each) do
      activate_authlogic
      UserSession.create!(tutor_user)
    end

    describe 'GET index' do
      it 'should respond ERROR not permitted' do
        get :index
        expect_bounce_as_not_allowed
      end
    end

    describe 'GET show' do
      it 'should respond ERROR not permitted' do
        get :show, id: 1
        expect_bounce_as_not_allowed
      end
    end

    describe 'GET new' do
      it 'should respond ERROR not permitted' do
        get :new
        expect_bounce_as_not_allowed
      end
    end

    describe 'GET edit' do
      it 'should respond ERROR not permitted' do
        get :edit, id: 1
        expect_bounce_as_not_allowed
      end
    end

    describe 'POST create' do
      it 'should respond ERROR not permitted' do
        post :create, country: valid_params
        expect_bounce_as_not_allowed
      end
    end

    describe 'PUT update' do
      it 'should respond ERROR not permitted' do
        put :update, id: 1, country: valid_params
        expect_bounce_as_not_allowed
      end
    end

    describe 'POST reorder' do
      it 'should respond ERROR not permitted' do
        post :create, array_of_ids: [1,2]
        expect_bounce_as_not_allowed
      end
    end

    describe 'DELETE destroy' do
      it 'should respond ERROR not permitted' do
        delete :destroy, id: 1
        expect_bounce_as_not_allowed
      end
    end

  end

  context 'Logged in as a system_requirements_user: ' do

    before(:each) do
      activate_authlogic
      UserSession.create!(system_requirements_user)
    end

    describe 'GET index' do
      it 'should respond OK' do
        get :index
        expect_index_success_with_model('countries', 3)
      end
    end

    describe 'GET show' do
      it 'should see uk' do
        get :show, id: uk.id
        expect_show_success_with_model('country', uk.id)
      end

      it 'should see ireland' do
        get :show, id: ireland.id
        expect_show_success_with_model('country', ireland.id)
      end
    end

    describe 'GET new' do
      it 'should respond OK' do
        get :new
        expect_new_success_with_model('country')
      end
    end

    describe 'GET edit' do
      it 'should respond OK with uk' do
        get :edit, id: uk.id
        expect_edit_success_with_model('country', uk.id)
      end

      it 'should respond OK with ireland' do
        get :edit, id: ireland.id
        expect_edit_success_with_model('country', ireland.id)
      end
    end

    describe 'POST create' do
      it 'should report OK for valid params' do
        post :create, country: valid_params
        expect_create_success_with_model('country', countries_url)
      end

      it 'should report error for invalid params' do
        post :create, country: {valid_params.keys.first => ''}
        expect_create_error_with_model('country')
      end
    end

    describe 'PUT update' do
      it 'should respond OK to valid params for uk' do
        put :update, id: uk.id, country: valid_params
        expect_update_success_with_model('country', countries_url)
      end

      it 'should respond OK to valid params for ireland' do
        put :update, id: ireland.id, country: valid_params
        expect_update_success_with_model('country', countries_url)
        expect(assigns(:country).id).to eq(ireland.id)
      end

      it 'should reject invalid params' do
        put :update, id: uk.id, country: {valid_params.keys.first => ''}
        expect_update_error_with_model('country')
        expect(assigns(:country).id).to eq(uk.id)
      end
    end

    describe 'POST reorder' do
      it 'should be OK with valid_array' do
        post :reorder, array_of_ids: [ireland.id, uk.id]
        expect_reorder_success
      end
    end

    describe 'DELETE destroy' do
      it 'should be ERROR as children exist' do
        delete :destroy, id: uk.id
        expect_delete_error_with_model('country', countries_url)
      end
    end

  end

  context 'Logged in as a content_management_user: ' do

    before(:each) do
      activate_authlogic
      UserSession.create!(content_management_user)
    end

    describe 'GET index' do
      it 'should respond ERROR not permitted' do
        get :index
        expect_bounce_as_not_allowed
      end
    end

    describe 'GET show' do
      it 'should respond ERROR not permitted' do
        get :show, id: 1
        expect_bounce_as_not_allowed
      end
    end

    describe 'GET new' do
      it 'should respond ERROR not permitted' do
        get :new
        expect_bounce_as_not_allowed
      end
    end

    describe 'GET edit' do
      it 'should respond ERROR not permitted' do
        get :edit, id: 1
        expect_bounce_as_not_allowed
      end
    end

    describe 'POST create' do
      it 'should respond ERROR not permitted' do
        post :create, country: valid_params
        expect_bounce_as_not_allowed
      end
    end

    describe 'PUT update' do
      it 'should respond ERROR not permitted' do
        put :update, id: 1, country: valid_params
        expect_bounce_as_not_allowed
      end
    end

    describe 'POST reorder' do
      it 'should respond ERROR not permitted' do
        post :create, array_of_ids: [1,2]
        expect_bounce_as_not_allowed
      end
    end

    describe 'DELETE destroy' do
      it 'should respond ERROR not permitted' do
        delete :destroy, id: 1
        expect_bounce_as_not_allowed
      end
    end

  end

  context 'Logged in as a stripe_management_user: ' do

    before(:each) do
      activate_authlogic
      UserSession.create!(stripe_management_user)
    end

    describe 'GET index' do
      it 'should respond ERROR not permitted' do
        get :index
        expect_bounce_as_not_allowed
      end
    end

    describe 'GET show' do
      it 'should respond ERROR not permitted' do
        get :show, id: 1
        expect_bounce_as_not_allowed
      end
    end

    describe 'GET new' do
      it 'should respond ERROR not permitted' do
        get :new
        expect_bounce_as_not_allowed
      end
    end

    describe 'GET edit' do
      it 'should respond ERROR not permitted' do
        get :edit, id: 1
        expect_bounce_as_not_allowed
      end
    end

    describe 'POST create' do
      it 'should respond ERROR not permitted' do
        post :create, country: valid_params
        expect_bounce_as_not_allowed
      end
    end

    describe 'PUT update' do
      it 'should respond ERROR not permitted' do
        put :update, id: 1, country: valid_params
        expect_bounce_as_not_allowed
      end
    end

    describe 'POST reorder' do
      it 'should respond ERROR not permitted' do
        post :create, array_of_ids: [1,2]
        expect_bounce_as_not_allowed
      end
    end

    describe 'DELETE destroy' do
      it 'should respond ERROR not permitted' do
        delete :destroy, id: 1
        expect_bounce_as_not_allowed
      end
    end

  end

  context 'Logged in as a user_management_user: ' do

    before(:each) do
      activate_authlogic
      UserSession.create!(user_management_user)
    end

    describe 'GET index' do
      it 'should respond ERROR not permitted' do
        get :index
        expect_bounce_as_not_allowed
      end
    end

    describe 'GET show' do
      it 'should respond ERROR not permitted' do
        get :show, id: 1
        expect_bounce_as_not_allowed
      end
    end

    describe 'GET new' do
      it 'should respond ERROR not permitted' do
        get :new
        expect_bounce_as_not_allowed
      end
    end

    describe 'GET edit' do
      it 'should respond ERROR not permitted' do
        get :edit, id: 1
        expect_bounce_as_not_allowed
      end
    end

    describe 'POST create' do
      it 'should respond ERROR not permitted' do
        post :create, country: valid_params
        expect_bounce_as_not_allowed
      end
    end

    describe 'PUT update' do
      it 'should respond ERROR not permitted' do
        put :update, id: 1, country: valid_params
        expect_bounce_as_not_allowed
      end
    end

    describe 'POST reorder' do
      it 'should respond ERROR not permitted' do
        post :create, array_of_ids: [1,2]
        expect_bounce_as_not_allowed
      end
    end

    describe 'DELETE destroy' do
      it 'should respond ERROR not permitted' do
        delete :destroy, id: 1
        expect_bounce_as_not_allowed
      end
    end

  end

  context 'Logged in as a developers_user: ' do

    before(:each) do
      activate_authlogic
      UserSession.create!(developers_user)
    end

    describe 'GET index' do
      it 'should respond ERROR not permitted' do
        get :index
        expect_bounce_as_not_allowed
      end
    end

    describe 'GET show' do
      it 'should respond ERROR not permitted' do
        get :show, id: 1
        expect_bounce_as_not_allowed
      end
    end

    describe 'GET new' do
      it 'should respond ERROR not permitted' do
        get :new
        expect_bounce_as_not_allowed
      end
    end

    describe 'GET edit' do
      it 'should respond ERROR not permitted' do
        get :edit, id: 1
        expect_bounce_as_not_allowed
      end
    end

    describe 'POST create' do
      it 'should respond ERROR not permitted' do
        post :create, country: valid_params
        expect_bounce_as_not_allowed
      end
    end

    describe 'PUT update' do
      it 'should respond ERROR not permitted' do
        put :update, id: 1, country: valid_params
        expect_bounce_as_not_allowed
      end
    end

    describe 'POST reorder' do
      it 'should respond ERROR not permitted' do
        post :create, array_of_ids: [1,2]
        expect_bounce_as_not_allowed
      end
    end

    describe 'DELETE destroy' do
      it 'should respond ERROR not permitted' do
        delete :destroy, id: 1
        expect_bounce_as_not_allowed
      end
    end

  end

  context 'Logged in as a marketing_manager_user: ' do

    before(:each) do
      activate_authlogic
      UserSession.create!(marketing_manager_user)
    end

    describe 'GET index' do
      it 'should respond ERROR not permitted' do
        get :index
        expect_bounce_as_not_allowed
      end
    end

    describe 'GET show' do
      it 'should respond ERROR not permitted' do
        get :show, id: 1
        expect_bounce_as_not_allowed
      end
    end

    describe 'GET new' do
      it 'should respond ERROR not permitted' do
        get :new
        expect_bounce_as_not_allowed
      end
    end

    describe 'GET edit' do
      it 'should respond ERROR not permitted' do
        get :edit, id: 1
        expect_bounce_as_not_allowed
      end
    end

    describe 'POST create' do
      it 'should respond ERROR not permitted' do
        post :create, country: valid_params
        expect_bounce_as_not_allowed
      end
    end

    describe 'PUT update' do
      it 'should respond ERROR not permitted' do
        put :update, id: 1, country: valid_params
        expect_bounce_as_not_allowed
      end
    end

    describe 'POST reorder' do
      it 'should respond ERROR not permitted' do
        post :create, array_of_ids: [1,2]
        expect_bounce_as_not_allowed
      end
    end

    describe 'DELETE destroy' do
      it 'should respond ERROR not permitted' do
        delete :destroy, id: 1
        expect_bounce_as_not_allowed
      end
    end

  end

  context 'Logged in as a user_group_manager_user: ' do

    before(:each) do
      activate_authlogic
      UserSession.create!(user_group_manager_user)
    end

    describe 'GET index' do
      it 'should respond ERROR not permitted' do
        get :index
        expect_bounce_as_not_allowed
      end
    end

    describe 'GET show' do
      it 'should respond ERROR not permitted' do
        get :show, id: 1
        expect_bounce_as_not_allowed
      end
    end

    describe 'GET new' do
      it 'should respond ERROR not permitted' do
        get :new
        expect_bounce_as_not_allowed
      end
    end

    describe 'GET edit' do
      it 'should respond ERROR not permitted' do
        get :edit, id: 1
        expect_bounce_as_not_allowed
      end
    end

    describe 'POST create' do
      it 'should respond ERROR not permitted' do
        post :create, country: valid_params
        expect_bounce_as_not_allowed
      end
    end

    describe 'PUT update' do
      it 'should respond ERROR not permitted' do
        put :update, id: 1, country: valid_params
        expect_bounce_as_not_allowed
      end
    end

    describe 'POST reorder' do
      it 'should respond ERROR not permitted' do
        post :create, array_of_ids: [1,2]
        expect_bounce_as_not_allowed
      end
    end

    describe 'DELETE destroy' do
      it 'should respond ERROR not permitted' do
        delete :destroy, id: 1
        expect_bounce_as_not_allowed
      end
    end

  end

  context 'Logged in as a admin_user: ' do

    before(:each) do
      activate_authlogic
      UserSession.create!(admin_user)
    end

    describe 'GET index' do
      it 'should respond OK' do
        get :index
        expect_index_success_with_model('countries', 3)
      end
    end

    describe 'GET show' do
      it 'should see uk' do
        get :show, id: uk.id
        expect_show_success_with_model('country', uk.id)
      end

      it 'should see ireland' do
        get :show, id: ireland.id
        expect_show_success_with_model('country', ireland.id)
      end
    end

    describe 'GET new' do
      it 'should respond OK' do
        get :new
        expect_new_success_with_model('country')
      end
    end

    describe 'GET edit' do
      it 'should respond OK with uk' do
        get :edit, id: uk.id
        expect_edit_success_with_model('country', uk.id)
      end

      it 'should respond OK with ireland' do
        get :edit, id: ireland.id
        expect_edit_success_with_model('country', ireland.id)
      end
    end

    describe 'POST create' do
      it 'should report OK for valid params' do
        post :create, country: valid_params
        expect_create_success_with_model('country', countries_url)
      end

      it 'should report error for invalid params' do
        post :create, country: {valid_params.keys.first => ''}
        expect_create_error_with_model('country')
      end
    end

    describe 'PUT update' do
      it 'should respond OK to valid params for uk' do
        put :update, id: uk.id, country: valid_params
        expect_update_success_with_model('country', countries_url)
      end

      it 'should respond OK to valid params for ireland' do
        put :update, id: ireland.id, country: valid_params
        expect_update_success_with_model('country', countries_url)
        expect(assigns(:country).id).to eq(ireland.id)
      end

      it 'should reject invalid params' do
        put :update, id: uk.id, country: {valid_params.keys.first => ''}
        expect_update_error_with_model('country')
        expect(assigns(:country).id).to eq(uk.id)
      end
    end

    describe 'POST reorder' do
      it 'should be OK with valid_array' do
        post :reorder, array_of_ids: [ireland.id, uk.id]
        expect_reorder_success
      end
    end

    describe 'DELETE destroy' do
      it 'should be ERROR as children exist' do
        delete :destroy, id: uk.id
        expect_delete_error_with_model('country', countries_url)
      end
    end

  end

end
