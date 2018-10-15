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

describe ExternalBannersController, type: :controller do

  let(:marketing_manager_user_group) { FactoryBot.create(:marketing_manager_user_group) }
  let(:marketing_manager_user) { FactoryBot.create(:marketing_manager_user, user_group_id: marketing_manager_user_group.id) }
  let!(:marketing_manager_student_access) { FactoryBot.create(:complimentary_student_access, user_id: marketing_manager_user.id) }

  let!(:external_banner_1) { FactoryBot.create(:external_banner) }
  let!(:external_banner_2) { FactoryBot.create(:external_banner) }
  let!(:valid_params) { FactoryBot.attributes_for(:external_banner) }

  context 'Logged in as a marketing_manager_user: ' do

    before(:each) do
      activate_authlogic
      UserSession.create!(marketing_manager_user)
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
      it 'should be OK as no dependencies exist' do
        delete :destroy, id: external_banner_2.id
        expect_delete_success_with_model('external_banner', external_banners_url)
      end
    end

  end

end
