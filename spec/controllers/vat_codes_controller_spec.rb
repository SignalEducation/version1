# == Schema Information
#
# Table name: vat_codes
#
#  id         :integer          not null, primary key
#  country_id :integer
#  name       :string
#  label      :string
#  wiki_url   :string
#  created_at :datetime
#  updated_at :datetime
#

require 'rails_helper'

describe VatCodesController, type: :controller do

  let(:system_requirements_user_group) { FactoryBot.create(:system_requirements_user_group) }
  let(:system_requirements_user) { FactoryBot.create(:system_requirements_user, user_group_id: system_requirements_user_group.id) }
  let!(:system_requirements_student_access) { FactoryBot.create(:complimentary_student_access, user_id: system_requirements_user.id) }

  let!(:uk) { FactoryBot.create(:uk) }
  let!(:vat_code_1) { FactoryBot.create(:vat_code, country: uk) }
  let!(:vat_rate) { FactoryBot.create(:vat_rate, vat_code_id: vat_code_1.id) }
  let!(:ireland) { FactoryBot.create(:ireland) }
  let!(:vat_code_2) { FactoryBot.create(:vat_code, country: ireland) }
  let!(:valid_params) { FactoryBot.attributes_for(:vat_code) }

  context 'Logged in as a system_requirements_user: ' do

    before(:each) do
      activate_authlogic
      UserSession.create!(system_requirements_user)
    end

    describe "GET 'index'" do
      it 'should respond OK' do
        get :index
        expect_index_success_with_model('vat_codes', 2)
      end
    end

    describe "GET 'show/1'" do
      it 'should see vat_code_1' do
        get :show, params: { id: vat_code_1.id }
        expect_show_success_with_model('vat_code', vat_code_1.id)
      end

      # optional - some other object
      it 'should see vat_code_2' do
        get :show, params: { id: vat_code_2.id }
        expect_show_success_with_model('vat_code', vat_code_2.id)
      end
    end

    describe "GET 'new'" do
      it 'should respond OK' do
        get :new
        expect_new_success_with_model('vat_code')
      end
    end

    describe "GET 'edit/1'" do
      it 'should respond OK with vat_code_1' do
        get :edit, params: { id: vat_code_1.id }
        expect_edit_success_with_model('vat_code', vat_code_1.id)
      end

      # optional
      it 'should respond OK with vat_code_2' do
        get :edit, params: { id: vat_code_2.id }
        expect_edit_success_with_model('vat_code', vat_code_2.id)
      end
    end

    describe "POST 'create'" do
      it 'should report OK for valid params' do
        post :create, params: { vat_code: valid_params }
        expect_create_success_with_model('vat_code', vat_codes_url)
      end

      it 'should report error for invalid params' do
        post :create, params: { vat_code: {valid_params.keys.first => ''} }
        expect_create_error_with_model('vat_code')
      end
    end

    describe "PUT 'update/1'" do
      it 'should respond OK to valid params for vat_code_1' do
        put :update, params: { id: vat_code_1.id, vat_code: valid_params }
        expect_update_success_with_model('vat_code', vat_codes_url)
      end

      # optional
      it 'should respond OK to valid params for vat_code_2' do
        put :update, params: { id: vat_code_2.id, vat_code: valid_params }
        expect_update_success_with_model('vat_code', vat_codes_url)
        expect(assigns(:vat_code).id).to eq(vat_code_2.id)
      end

      it 'should reject invalid params' do
        put :update, params: { id: vat_code_1.id, vat_code: {valid_params.keys.first => ''} }
        expect_update_error_with_model('vat_code')
        expect(assigns(:vat_code).id).to eq(vat_code_1.id)
      end
    end


    describe "DELETE 'destroy'" do
      it 'should be ERROR as children exist' do
        delete :destroy, params: { id: vat_code_1.id }
        expect_delete_error_with_model('vat_code', vat_codes_url)
      end

      it 'should be OK as no dependencies exist' do
        delete :destroy, params: { id: vat_code_2.id }
        expect_delete_success_with_model('vat_code', vat_codes_url)
      end
    end

  end

end
