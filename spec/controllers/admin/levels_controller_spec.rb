require 'rails_helper'

describe Admin::LevelsController, type: :controller do
  let(:content_management_user_group)  { create(:content_management_user_group) }
  let(:content_management_user)        { create(:content_management_user, user_group_id: content_management_user_group.id) }
  let!(:group_1)                 { create(:group) }
  let!(:group_2)                 { create(:group) }
  let!(:level_1)                 { create(:level, group_id: group_1.id) }
  let!(:level_2)                 { create(:level, group_id: group_2.id) }
  let!(:valid_params) { attributes_for(:level, group_id: group_1.id) }


  context 'Logged in as a content_management_user: ' do
    before(:each) do
      activate_authlogic
      UserSession.create!(content_management_user)
    end

    describe "GET 'index'" do
      it 'should respond OK' do
        get :index
        expect_index_success_with_model('levels', 2)
      end

      it 'should respond OK group filter' do
        get :index, params: { group_id: group_1.id }
        expect_index_success_with_model('levels', 1)
      end

      it 'should respond OK search' do
        get :index, params: { search: level_1.name }
        expect_index_success_with_model('levels', 1)
      end
    end

    describe "GET 'new'" do
      it 'should respond OK' do
        get :new
        expect_new_success_with_model('level')
      end
    end

    describe "GET 'edit/1'" do
      it 'should respond OK with level_1' do
        get :edit, params: { id: level_1.id }
        expect_edit_success_with_model('level', level_1.id)
      end

      # optional
      it 'should respond OK with group_2' do
        get :edit, params: { id: level_2.id }
        expect_edit_success_with_model('level', level_2.id)
      end
    end

    describe "POST 'create'" do
      it 'should report OK for valid params' do
        post :create, params: { level: valid_params }
        expect_create_success_with_model('level', admin_levels_url)
      end

      it 'should report error for invalid params' do
        post :create, params: { level: {valid_params.keys.first => ''} }
        expect_create_error_with_model('level')
      end
    end

    describe "PUT 'update/1'" do
      it 'should respond OK to valid params for level_1' do
        put :update, params: { id: level_1.id, level: valid_params }
        expect_update_success_with_model('level', admin_levels_url)
      end

      # optional
      it 'should respond OK to valid params for level_2' do
        put :update, params: { id: level_2.id, level: valid_params }
        expect_update_success_with_model('level', admin_levels_url)
        expect(assigns(:level).id).to eq(level_2.id)
      end

      it 'should reject invalid params' do
        put :update, params: { id: level_1.id, level: {valid_params.keys.first => ''} }
        expect_update_error_with_model('level')
        expect(assigns(:level).id).to eq(level_1.id)
      end
    end

    describe "POST 'reorder'" do
      it 'should be OK with valid_array' do
        post :reorder, params: { array_of_ids: [level_2.id, level_1.id] }
        expect_reorder_success
      end
    end

    describe "DELETE 'destroy'" do
      it 'should be OK as no dependencies exist' do
        delete :destroy, params: { id: level_2.id }
        expect_delete_success_with_model('level', admin_levels_url)
      end
    end

  end

end
