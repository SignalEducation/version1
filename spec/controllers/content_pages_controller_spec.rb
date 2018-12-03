# == Schema Information
#
# Table name: content_pages
#
#  id              :integer          not null, primary key
#  name            :string
#  public_url      :string
#  seo_title       :string
#  seo_description :text
#  text_content    :text
#  h1_text         :string
#  h1_subtext      :string
#  nav_type        :string
#  footer_link     :boolean          default(FALSE)
#  created_at      :datetime         not null
#  updated_at      :datetime         not null
#  active          :boolean          default(FALSE)
#

require 'rails_helper'

describe ContentPagesController, type: :controller do

  let(:marketing_manager_user_group) { FactoryBot.create(:marketing_manager_user_group) }
  let(:marketing_manager_user) { FactoryBot.create(:marketing_manager_user,
                                                   user_group_id: marketing_manager_user_group.id) }
  let!(:marketing_manager_student_access) { FactoryBot.create(:complimentary_student_access,
                                                              user_id: marketing_manager_user.id) }

  let!(:content_page_1) { FactoryBot.create(:content_page, active: true) }
  let!(:content_page_2) { FactoryBot.create(:content_page) }
  let!(:external_banner) { FactoryBot.create(:external_banner, content_page_id: content_page_1.id) }

  let!(:valid_params) { FactoryBot.attributes_for(:content_page) }


  context 'Logged in as a marketing_manager_user: ' do

    before(:each) do
      activate_authlogic
      UserSession.create!(marketing_manager_user)
    end

    describe "GET 'index'" do
      it 'should respond OK' do
        get :index
        expect_index_success_with_model('content_pages', 2)
      end
    end

    describe "GET 'show/1'" do
      it 'should see content_page_1' do
        get :show, content_public_url: content_page_1.public_url
        expect_show_success_with_model('content_page', content_page_1.id)
      end

      # optional - some other object
      it 'should see content_page_2' do
        get :show, content_public_url: content_page_2.public_url
        expect_show_success_with_model('content_page', content_page_2.id)
      end
    end

    describe "GET 'new'" do
      it 'should respond OK' do
        get :new
        expect_new_success_with_model('content_page')
      end
    end

    describe "GET 'edit/1'" do
      it 'should respond OK with content_page_1' do
        get :edit, id: content_page_1.id
        expect_edit_success_with_model('content_page', content_page_1.id)
      end

      # optional
      it 'should respond OK with content_page_2' do
        get :edit, id: content_page_2.id
        expect_edit_success_with_model('content_page', content_page_2.id)
      end
    end

    describe "POST 'create'" do
      it 'should report OK for valid params' do
        post :create, content_page: valid_params
        expect_create_success_with_model('content_page', content_pages_url)
      end

      it 'should report error for invalid params' do
        post :create, content_page: {valid_params.keys.first => ''}
        expect_create_error_with_model('content_page')
      end
    end

    describe "PUT 'update/1'" do
      it 'should respond OK to valid params for content_page_1' do
        put :update, id: content_page_1.id, content_page: valid_params
        expect_update_success_with_model('content_page', content_pages_url)
      end

      # optional
      it 'should respond OK to valid params for content_page_2' do
        put :update, id: content_page_2.id, content_page: valid_params
        expect_update_success_with_model('content_page', content_pages_url)
        expect(assigns(:content_page).id).to eq(content_page_2.id)
      end

      it 'should reject invalid params' do
        put :update, id: content_page_1.id, content_page: {valid_params.keys.first => ''}
        expect_update_error_with_model('content_page')
        expect(assigns(:content_page).id).to eq(content_page_1.id)
      end
    end


    describe "DELETE 'destroy'" do
      it 'should be ERROR as children exist' do
        delete :destroy, id: content_page_1.id
        expect_delete_success_with_model('content_page', content_pages_url)
      end

      it 'should be OK as no dependencies exist' do
        delete :destroy, id: content_page_2.id
        expect_delete_success_with_model('content_page', content_pages_url)
      end
    end

  end

  context 'Not logged in...' do

    describe "GET 'show/1'" do
      it 'should see content_page_1' do
        get :show, content_public_url: content_page_1.public_url
        expect_show_success_with_model('content_page', content_page_1.id)
      end
    end
  end

end
