# == Schema Information
#
# Table name: groups
#
#  id                            :integer          not null, primary key
#  name                          :string
#  name_url                      :string
#  active                        :boolean          default(FALSE), not null
#  sorting_order                 :integer
#  description                   :text
#  created_at                    :datetime         not null
#  updated_at                    :datetime         not null
#  destroyed_at                  :datetime
#  image_file_name               :string
#  image_content_type            :string
#  image_file_size               :integer
#  image_updated_at              :datetime
#  background_image_file_name    :string
#  background_image_content_type :string
#  background_image_file_size    :integer
#  background_image_updated_at   :datetime
#

require 'rails_helper'

describe GroupsController, type: :controller do
  let(:content_management_user_group) { create(:content_management_user_group) }
  let(:content_management_user)       { create(:content_management_user, user_group_id: content_management_user_group.id) }
  let!(:exam_body_1)                  { create(:exam_body) }
  let!(:category)                     { create(:category) }
  let!(:sub_category)                 { create(:sub_category, category: category) }
  let!(:group_1)                      { create(:group, category: category, sub_category: sub_category) }
  let!(:group_2)                      { create(:group, category: category, sub_category: sub_category) }
  let!(:valid_params)                 { attributes_for(:group,
                                                        exam_body_id: exam_body_1.id,
                                                        category_id: category.id,
                                                        sub_category_id: sub_category.id) }

  context 'Logged in as a content_management_user: ' do
    before(:each) do
      activate_authlogic
      UserSession.create!(content_management_user)
    end

    describe "GET 'index'" do
      it 'should respond OK' do
        get :index
        expect_index_success_with_model('groups', 2)
      end
    end

    describe "GET 'new'" do
      it 'should respond OK' do
        get :new
        expect_new_success_with_model('group')
      end
    end

    describe "GET 'edit/1'" do
      it 'should respond OK with group_1' do
        get :edit, params: { id: group_1.id }
        expect_edit_success_with_model('group', group_1.id)
      end

      # optional
      it 'should respond OK with group_2' do
        get :edit, params: { id: group_2.id }
        expect_edit_success_with_model('group', group_2.id)
      end
    end

    describe "POST 'create'" do
      it 'should report OK for valid params' do
        post :create, params: { group: valid_params }
        expect_create_success_with_model('group', groups_url)
      end

      it 'should report error for invalid params' do
        post :create, params: { group: {valid_params.keys.first => ''} }
        expect_create_error_with_model('group')
      end
    end

    describe "PUT 'update/1'" do
      it 'should respond OK to valid params for group_1' do
        put :update, params: { id: group_1.id, group: valid_params }
        expect_update_success_with_model('group', groups_url)
      end

      # optional
      it 'should respond OK to valid params for group_2' do
        put :update, params: { id: group_2.id, group: valid_params }
        expect_update_success_with_model('group', groups_url)
        expect(assigns(:group).id).to eq(group_2.id)
      end

      it 'should reject invalid params' do
        put :update, params: { id: group_1.id, group: {valid_params.keys.first => ''} }
        expect_update_error_with_model('group')
        expect(assigns(:group).id).to eq(group_1.id)
      end
    end

    describe "POST 'reorder'" do
      it 'should be OK with valid_array' do
        post :reorder, params: { array_of_ids: [group_2.id, group_1.id] }
        expect_reorder_success
      end
    end

    describe "DELETE 'destroy'" do
      it 'should be OK as no dependencies exist' do
        delete :destroy, params: { id: group_2.id }
        expect_delete_success_with_model('group', groups_url)
      end
    end
  end
end
