# == Schema Information
#
# Table name: currencies
#
#  id              :integer          not null, primary key
#  iso_code        :string
#  name            :string
#  leading_symbol  :string
#  trailing_symbol :string
#  active          :boolean          default(FALSE), not null
#  sorting_order   :integer
#  created_at      :datetime
#  updated_at      :datetime
#

require 'rails_helper'

describe CurrenciesController, type: :controller do

  let(:system_requirements_user_group) { create(:system_requirements_user_group) }
  let(:system_requirements_user) { 
    create(
      :system_requirements_user,
      user_group: system_requirements_user_group,
      country: nil
    )
  }
  let(:system_requirements_student_access) { create(:complimentary_student_access,
                                                                user: system_requirements_user) }

  let!(:currency_1) { create(:gbp) }
  let!(:currency_2) { create(:usd) }
  let(:valid_params) { attributes_for(:currency) }

  context 'Logged in as a system_requirements_user: ' do

    before(:each) do
      activate_authlogic
      UserSession.create!(system_requirements_user)
    end

    describe "GET 'index'" do
      it 'should respond OK' do
        get :index
        expect_index_success_with_model('currencies', 2)
      end
    end

    describe "GET 'show/1'" do
      it 'should see currency_1' do
        get :show, params: { id: currency_1.id }
        expect_show_success_with_model('currency', currency_1.id)
      end

      # optional - some other object
      it 'should see currency_2' do
        get :show, params: { id: currency_2.id }
        expect_show_success_with_model('currency', currency_2.id)
      end
    end

    describe "GET 'new'" do
      it 'should respond OK' do
        get :new
        expect_new_success_with_model('currency')
      end
    end

    describe "GET 'edit/1'" do
      it 'should respond OK with currency_1' do
        get :edit, params: { id: currency_1.id }
        expect_edit_success_with_model('currency', currency_1.id)
      end

      # optional
      it 'should respond OK with currency_2' do
        get :edit, params: { id: currency_2.id }
        expect_edit_success_with_model('currency', currency_2.id)
      end
    end

    describe "POST 'create'" do
      it 'should report OK for valid params' do
        post :create, params: { currency: valid_params }
        expect_create_success_with_model('currency', currencies_url)
      end

      it 'should report error for invalid params' do
        post :create, params: { currency: {valid_params.keys.first => ''} }
        expect_create_error_with_model('currency')
      end
    end

    describe "PUT 'update/1'" do
      it 'should respond OK to valid params for currency_1' do
        put :update, params: { id: currency_1.id, currency: valid_params }
        expect_update_success_with_model('currency', currencies_url)
      end

      # optional
      it 'should respond OK to valid params for currency_2' do
        put :update, params: { id: currency_2.id, currency: valid_params }
        expect_update_success_with_model('currency', currencies_url)
        expect(assigns(:currency).id).to eq(currency_2.id)
      end

      it 'should reject invalid params' do
        put :update, params: { id: currency_1.id, currency: {valid_params.keys.first => ''} }
        expect_update_error_with_model('currency')
        expect(assigns(:currency).id).to eq(currency_1.id)
      end
    end

    describe "POST 'reorder'" do
      it 'should be OK with valid_array' do
        post :reorder, params: { array_of_ids: [currency_2.id, currency_1.id] }
        expect_reorder_success
      end
    end

    describe "DELETE 'destroy'" do
      it 'should be ERROR as children exist or currency is active' do
        delete :destroy, params: { id: currency_1.id }
        expect_delete_success_with_model('currency', currencies_url)
      end
    end
  end
end
