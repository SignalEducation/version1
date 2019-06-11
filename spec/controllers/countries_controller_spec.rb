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

describe CountriesController, type: :controller do

  let(:system_requirements_user_group) { FactoryBot.create(:system_requirements_user_group) }
  let(:system_requirements_user) { FactoryBot.create(:system_requirements_user,
                                                     user_group_id: system_requirements_user_group.id) }

  let!(:gbp) { FactoryBot.create(:gbp) }
  let!(:eur) { FactoryBot.create(:euro) }

  let!(:uk) { FactoryBot.create(:uk, currency_id: gbp.id) }
  let!(:ireland) { FactoryBot.create(:ireland, currency_id: eur.id) }

  let!(:valid_params) { FactoryBot.attributes_for(:fr, currency_id: eur.id) }

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
        get :show, params: { id: uk.id }
        expect_show_success_with_model('country', uk.id)
      end

      it 'should see ireland' do
        get :show, params: { id: ireland.id }
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
        get :edit, params: { id: uk.id }
        expect_edit_success_with_model('country', uk.id)
      end

      it 'should respond OK with ireland' do
        get :edit, params: { id: ireland.id }
        expect_edit_success_with_model('country', ireland.id)
      end
    end

    describe 'POST create' do
      it 'should report OK for valid params' do
        post :create, params: { country: valid_params }
        expect_create_success_with_model('country', countries_url)
      end

      it 'should report error for invalid params' do
        post :create, params: { country: {valid_params.keys.first => ''} }
        expect_create_error_with_model('country')
      end
    end

    describe 'PUT update' do
      it 'should respond OK to valid params for uk' do
        put :update, params: { id: uk.id, country: valid_params }
        expect_update_success_with_model('country', countries_url)
      end

      it 'should respond OK to valid params for ireland' do
        put :update, params: { id: ireland.id, country: valid_params }
        expect_update_success_with_model('country', countries_url)
        expect(assigns(:country).id).to eq(ireland.id)
      end

      it 'should reject invalid params' do
        put :update, params: { id: uk.id, country: {valid_params.keys.first => ''} }
        expect_update_error_with_model('country')
        expect(assigns(:country).id).to eq(uk.id)
      end
    end

    describe 'POST reorder' do
      it 'should be OK with valid_array' do
        post :reorder, params: { array_of_ids: [ireland.id, uk.id] }
        expect_reorder_success
      end
    end

    describe 'DELETE destroy' do
      it 'should be ERROR' do
        delete :destroy, params: { id: uk.id }
        expect_delete_error_with_model('country', countries_url)
      end
    end

  end

end
