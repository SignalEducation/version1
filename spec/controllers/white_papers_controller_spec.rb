# == Schema Information
#
# Table name: white_papers
#
#  id                       :integer          not null, primary key
#  description              :text
#  created_at               :datetime         not null
#  updated_at               :datetime         not null
#  file_file_name           :string
#  file_content_type        :string
#  file_file_size           :integer
#  file_updated_at          :datetime
#  sorting_order            :integer
#  cover_image_file_name    :string
#  cover_image_content_type :string
#  cover_image_file_size    :integer
#  cover_image_updated_at   :datetime
#  name_url                 :string
#  name                     :string
#  subject_course_id        :integer
#

require 'rails_helper'
require 'support/users_and_groups_setup'

describe WhitePapersController, type: :controller do

  include_context 'users_and_groups_setup'

  let!(:white_paper_1) { FactoryGirl.create(:white_paper) }
  let!(:white_paper_2) { FactoryGirl.create(:white_paper) }
  let!(:valid_params) { FactoryGirl.attributes_for(:white_paper) }
  let!(:request_params) { FactoryGirl.attributes_for(:white_paper_request, white_paper_id: white_paper_1.id) }

  context 'Not logged in: ' do

    describe "GET 'index'" do
      it 'should redirect to sign_in' do
        get :index
        expect_bounce_as_not_signed_in
      end
    end

    describe "GET 'media_library'" do
      it 'should render public index' do
        get :media_library
        expect(flash[:success]).to be_nil
        expect(flash[:error]).to be_nil
        expect(response.status).to eq(200)
        expect(response).to render_template(:media_library)
        expect(assigns('white_papers'.to_sym).first.class.name).to eq('white_papers'.classify)
      end
    end

    describe "GET 'show/1'" do
      it 'should render  show' do
        get :show, white_paper_name_url: white_paper_1.name_url, id: white_paper_1.id
        expect_show_success_with_model('white_paper', white_paper_1.id)
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

    describe "POST 'create_request'" do
      it 'should report OK for valid params' do
        post :create_request, white_paper_request: request_params
        expect_create_success_with_model('white_paper_request', public_white_paper_url(white_paper_1.name_url))
      end
    end

    describe "PUT 'update/1'" do
      it 'should redirect to sign_in' do
        put :update, id: 1, user: valid_params
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
      it 'should redirect to sign_in' do
        get :index
        expect_bounce_as_not_allowed
      end
    end

    describe "GET 'media_library'" do
      it 'should render public index' do
        get :media_library
        expect(flash[:success]).to be_nil
        expect(flash[:error]).to be_nil
        expect(response.status).to eq(200)
        expect(response).to render_template(:media_library)
        expect(assigns('white_papers'.to_sym).first.class.name).to eq('white_papers'.classify)
      end
    end

    describe "GET 'show/1'" do
      it 'should render  show' do
        get :show, white_paper_name_url: white_paper_1.name_url, id: white_paper_1.id
        expect_show_success_with_model('white_paper', white_paper_1.id)
      end
    end

    describe "GET 'new'" do
      it 'should redirect to sign_in' do
        get :new
        expect_bounce_as_not_allowed
      end
    end

    describe "GET 'edit/1'" do
      it 'should redirect to sign_in' do
        get :edit, id: 1
        expect_bounce_as_not_allowed
      end
    end

    describe "POST 'create'" do
      it 'should redirect to sign_in' do
        post :create, user: valid_params
        expect_bounce_as_not_allowed
      end
    end

    describe "POST 'create_request'" do
      it 'should report OK for valid params' do
        post :create_request, white_paper_request: request_params
        expect_create_success_with_model('white_paper_request', public_white_paper_url(white_paper_1.name_url))
      end
    end

    describe "PUT 'update/1'" do
      it 'should redirect to sign_in' do
        put :update, id: 1, user: valid_params
        expect_bounce_as_not_allowed
      end
    end


    describe "DELETE 'destroy'" do
      it 'should redirect to sign_in' do
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

    describe "GET 'index'" do
      it 'should redirect to sign_in' do
        get :index
        expect_bounce_as_not_allowed
      end
    end

    describe "GET 'media_library'" do
      it 'should render public index' do
        get :media_library
        expect(flash[:success]).to be_nil
        expect(flash[:error]).to be_nil
        expect(response.status).to eq(200)
        expect(response).to render_template(:media_library)
        expect(assigns('white_papers'.to_sym).first.class.name).to eq('white_papers'.classify)
      end
    end

    describe "GET 'show/1'" do
      it 'should render  show' do
        get :show, white_paper_name_url: white_paper_1.name_url, id: white_paper_1.id
        expect_show_success_with_model('white_paper', white_paper_1.id)
      end
    end

    describe "GET 'new'" do
      it 'should redirect to sign_in' do
        get :new
        expect_bounce_as_not_allowed
      end
    end

    describe "GET 'edit/1'" do
      it 'should redirect to sign_in' do
        get :edit, id: 1
        expect_bounce_as_not_allowed
      end
    end

    describe "POST 'create'" do
      it 'should redirect to sign_in' do
        post :create, user: valid_params
        expect_bounce_as_not_allowed
      end
    end

    describe "POST 'create_request'" do
      it 'should report OK for valid params' do
        post :create_request, white_paper_request: request_params
        expect_create_success_with_model('white_paper_request', public_white_paper_url(white_paper_1.name_url))
      end
    end

    describe "PUT 'update/1'" do
      it 'should redirect to sign_in' do
        put :update, id: 1, user: valid_params
        expect_bounce_as_not_allowed
      end
    end


    describe "DELETE 'destroy'" do
      it 'should redirect to sign_in' do
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
    describe "GET 'index'" do
      it 'should redirect to sign_in' do
        get :index
        expect_bounce_as_not_allowed
      end
    end

    describe "GET 'media_library'" do
      it 'should render public index' do
        get :media_library
        expect(flash[:success]).to be_nil
        expect(flash[:error]).to be_nil
        expect(response.status).to eq(200)
        expect(response).to render_template(:media_library)
        expect(assigns('white_papers'.to_sym).first.class.name).to eq('white_papers'.classify)
      end
    end

    describe "GET 'show/1'" do
      it 'should render  show' do
        get :show, white_paper_name_url: white_paper_1.name_url, id: white_paper_1.id
        expect_show_success_with_model('white_paper', white_paper_1.id)
      end
    end

    describe "GET 'new'" do
      it 'should redirect to sign_in' do
        get :new
        expect_bounce_as_not_allowed
      end
    end

    describe "GET 'edit/1'" do
      it 'should redirect to sign_in' do
        get :edit, id: 1
        expect_bounce_as_not_allowed
      end
    end

    describe "POST 'create'" do
      it 'should redirect to sign_in' do
        post :create, user: valid_params
        expect_bounce_as_not_allowed
      end
    end

    describe "POST 'create_request'" do
      it 'should report OK for valid params' do
        post :create_request, white_paper_request: request_params
        expect_create_success_with_model('white_paper_request', public_white_paper_url(white_paper_1.name_url))
      end
    end

    describe "PUT 'update/1'" do
      it 'should redirect to sign_in' do
        put :update, id: 1, user: valid_params
        expect_bounce_as_not_allowed
      end
    end


    describe "DELETE 'destroy'" do
      it 'should redirect to sign_in' do
        delete :destroy, id: 1
        expect_bounce_as_not_allowed
      end
    end

  end

  context 'Logged in as a corporate_student_user: ' do

    before(:each) do
      activate_authlogic
      UserSession.create!(corporate_student_user)
    end

    describe "GET 'index'" do
      it 'should redirect to sign_in' do
        get :index
        expect_bounce_as_not_allowed
      end
    end

    describe "GET 'media_library'" do
      it 'should render public index' do
        get :media_library
        expect(flash[:success]).to be_nil
        expect(flash[:error]).to be_nil
        expect(response.status).to eq(200)
        expect(response).to render_template(:media_library)
        expect(assigns('white_papers'.to_sym).first.class.name).to eq('white_papers'.classify)
      end
    end

    describe "GET 'show/1'" do
      it 'should render  show' do
        get :show, white_paper_name_url: white_paper_1.name_url, id: white_paper_1.id
        expect_show_success_with_model('white_paper', white_paper_1.id)
      end
    end

    describe "GET 'new'" do
      it 'should redirect to sign_in' do
        get :new
        expect_bounce_as_not_allowed
      end
    end

    describe "GET 'edit/1'" do
      it 'should redirect to sign_in' do
        get :edit, id: 1
        expect_bounce_as_not_allowed
      end
    end

    describe "POST 'create'" do
      it 'should redirect to sign_in' do
        post :create, user: valid_params
        expect_bounce_as_not_allowed
      end
    end

    describe "POST 'create_request'" do
      it 'should report OK for valid params' do
        post :create_request, white_paper_request: request_params
        expect_create_success_with_model('white_paper_request', public_white_paper_url(white_paper_1.name_url))
      end
    end

    describe "PUT 'update/1'" do
      it 'should redirect to sign_in' do
        put :update, id: 1, user: valid_params
        expect_bounce_as_not_allowed
      end
    end


    describe "DELETE 'destroy'" do
      it 'should redirect to sign_in' do
        delete :destroy, id: 1
        expect_bounce_as_not_allowed
      end
    end

  end

  context 'Logged in as a corporate_customer_user: ' do

    before(:each) do
      activate_authlogic
      UserSession.create!(corporate_customer_user)
    end

    describe "GET 'index'" do
      it 'should redirect to sign_in' do
        get :index
        expect_bounce_as_not_allowed
      end
    end

    describe "GET 'media_library'" do
      it 'should render public index' do
        get :media_library
        expect(flash[:success]).to be_nil
        expect(flash[:error]).to be_nil
        expect(response.status).to eq(200)
        expect(response).to render_template(:media_library)
        expect(assigns('white_papers'.to_sym).first.class.name).to eq('white_papers'.classify)
      end
    end

    describe "GET 'show/1'" do
      it 'should render  show' do
        get :show, white_paper_name_url: white_paper_1.name_url, id: white_paper_1.id
        expect_show_success_with_model('white_paper', white_paper_1.id)
      end
    end

    describe "GET 'new'" do
      it 'should redirect to sign_in' do
        get :new
        expect_bounce_as_not_allowed
      end
    end

    describe "GET 'edit/1'" do
      it 'should redirect to sign_in' do
        get :edit, id: 1
        expect_bounce_as_not_allowed
      end
    end

    describe "POST 'create'" do
      it 'should redirect to sign_in' do
        post :create, user: valid_params
        expect_bounce_as_not_allowed
      end
    end

    describe "POST 'create_request'" do
      it 'should report OK for valid params' do
        post :create_request, white_paper_request: request_params
        expect_create_success_with_model('white_paper_request', public_white_paper_url(white_paper_1.name_url))
      end
    end

    describe "PUT 'update/1'" do
      it 'should redirect to sign_in' do
        put :update, id: 1, user: valid_params
        expect_bounce_as_not_allowed
      end
    end


    describe "DELETE 'destroy'" do
      it 'should redirect to sign_in' do
        delete :destroy, id: 1
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
      it 'should redirect to sign_in' do
        get :index
        expect_bounce_as_not_allowed
      end
    end

    describe "GET 'media_library'" do
      it 'should render public index' do
        get :media_library
        expect(flash[:success]).to be_nil
        expect(flash[:error]).to be_nil
        expect(response.status).to eq(200)
        expect(response).to render_template(:media_library)
        expect(assigns('white_papers'.to_sym).first.class.name).to eq('white_papers'.classify)
      end
    end

    describe "GET 'show/1'" do
      it 'should render  show' do
        get :show, white_paper_name_url: white_paper_1.name_url, id: white_paper_1.id
        expect_show_success_with_model('white_paper', white_paper_1.id)
      end
    end

    describe "GET 'new'" do
      it 'should redirect to sign_in' do
        get :new
        expect_bounce_as_not_allowed
      end
    end

    describe "GET 'edit/1'" do
      it 'should redirect to sign_in' do
        get :edit, id: 1
        expect_bounce_as_not_allowed
      end
    end

    describe "POST 'create'" do
      it 'should redirect to sign_in' do
        post :create, user: valid_params
        expect_bounce_as_not_allowed
      end
    end

    describe "POST 'create_request'" do
      it 'should report OK for valid params' do
        post :create_request, white_paper_request: request_params
        expect_create_success_with_model('white_paper_request', public_white_paper_url(white_paper_1.name_url))
      end
    end

    describe "PUT 'update/1'" do
      it 'should redirect to sign_in' do
        put :update, id: 1, user: valid_params
        expect_bounce_as_not_allowed
      end
    end


    describe "DELETE 'destroy'" do
      it 'should redirect to sign_in' do
        delete :destroy, id: 1
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
      it 'should redirect to sign_in' do
        get :index
        expect_index_success_with_model('white_papers', white_paper_2.id)
      end
    end

    describe "GET 'media_library'" do
      it 'should render public index' do
        get :media_library
        expect(flash[:success]).to be_nil
        expect(flash[:error]).to be_nil
        expect(response.status).to eq(200)
        expect(response).to render_template(:media_library)
        expect(assigns('white_papers'.to_sym).first.class.name).to eq('white_papers'.classify)
      end
    end

    describe "GET 'show/1'" do
      it 'should render  show' do
        get :show, white_paper_name_url: white_paper_1.name_url, id: white_paper_1.id
        expect_show_success_with_model('white_paper', white_paper_1.id)
      end
    end

    describe "GET 'new'" do
      it 'should redirect to sign_in' do
        get :new
        expect_new_success_with_model('white_paper')
      end
    end

    describe "GET 'edit/1'" do
      it 'should redirect to sign_in' do
        get :edit, id: 1
        expect_edit_success_with_model('white_paper', white_paper_1.id)
      end
    end

    describe "POST 'create'" do
      it 'should redirect to sign_in' do
        post :create, white_paper: valid_params
        expect_create_success_with_model('white_paper', white_papers_url)
      end
    end

    describe "POST 'create_request'" do
      it 'should report OK for valid params' do
        post :create_request, white_paper_request: request_params
        expect_create_success_with_model('white_paper_request', public_white_paper_url(white_paper_1.name_url))
      end
    end

    describe "PUT 'update/1'" do
      it 'should redirect to sign_in' do
        put :update, id: 1, white_paper: valid_params
        expect_update_success_with_model('white_paper', white_papers_url)
      end
    end

    describe "DELETE 'destroy'" do
      it 'should redirect to sign_in' do
        delete :destroy, id: 1
        expect_delete_success_with_model('white_paper', white_papers_url)
      end
    end

  end

  context 'Logged in as a customer_support_manager_user: ' do

    before(:each) do
      activate_authlogic
      UserSession.create!(customer_support_manager_user)
    end

    describe "GET 'index'" do
      it 'should redirect to sign_in' do
        get :index
        expect_bounce_as_not_allowed
      end
    end

    describe "GET 'media_library'" do
      it 'should render public index' do
        get :media_library
        expect(flash[:success]).to be_nil
        expect(flash[:error]).to be_nil
        expect(response.status).to eq(200)
        expect(response).to render_template(:media_library)
        expect(assigns('white_papers'.to_sym).first.class.name).to eq('white_papers'.classify)
      end
    end

    describe "GET 'show/1'" do
      it 'should render  show' do
        get :show, white_paper_name_url: white_paper_1.name_url, id: white_paper_1.id
        expect_show_success_with_model('white_paper', white_paper_1.id)
      end
    end

    describe "GET 'new'" do
      it 'should redirect to sign_in' do
        get :new
        expect_bounce_as_not_allowed
      end
    end

    describe "GET 'edit/1'" do
      it 'should redirect to sign_in' do
        get :edit, id: 1
        expect_bounce_as_not_allowed
      end
    end

    describe "POST 'create'" do
      it 'should redirect to sign_in' do
        post :create, user: valid_params
        expect_bounce_as_not_allowed
      end
    end

    describe "POST 'create_request'" do
      it 'should report OK for valid params' do
        post :create_request, white_paper_request: request_params
        expect_create_success_with_model('white_paper_request', public_white_paper_url(white_paper_1.name_url))
      end
    end

    describe "PUT 'update/1'" do
      it 'should redirect to sign_in' do
        put :update, id: 1, user: valid_params
        expect_bounce_as_not_allowed
      end
    end


    describe "DELETE 'destroy'" do
      it 'should redirect to sign_in' do
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

    describe "GET 'index'" do
      it 'should redirect to sign_in' do
        get :index
        expect_bounce_as_not_allowed
      end
    end

    describe "GET 'media_library'" do
      it 'should render public index' do
        get :media_library
        expect(flash[:success]).to be_nil
        expect(flash[:error]).to be_nil
        expect(response.status).to eq(200)
        expect(response).to render_template(:media_library)
        expect(assigns('white_papers'.to_sym).first.class.name).to eq('white_papers'.classify)
      end
    end

    describe "GET 'show/1'" do
      it 'should render  show' do
        get :show, white_paper_name_url: white_paper_1.name_url, id: white_paper_1.id
        expect_show_success_with_model('white_paper', white_paper_1.id)
      end
    end

    describe "GET 'new'" do
      it 'should redirect to sign_in' do
        get :new
        expect_bounce_as_not_allowed
      end
    end

    describe "GET 'edit/1'" do
      it 'should redirect to sign_in' do
        get :edit, id: 1
        expect_bounce_as_not_allowed
      end
    end

    describe "POST 'create'" do
      it 'should redirect to sign_in' do
        post :create, user: valid_params
        expect_bounce_as_not_allowed
      end
    end

    describe "POST 'create_request'" do
      it 'should report OK for valid params' do
        post :create_request, white_paper_request: request_params
        expect_create_success_with_model('white_paper_request', public_white_paper_url(white_paper_1.name_url))
      end
    end

    describe "PUT 'update/1'" do
      it 'should redirect to sign_in' do
        put :update, id: 1, user: valid_params
        expect_bounce_as_not_allowed
      end
    end


    describe "DELETE 'destroy'" do
      it 'should redirect to sign_in' do
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

    describe "GET 'index'" do
      it 'should redirect to sign_in' do
        get :index
        expect_index_success_with_model('white_papers', white_paper_2.id)
      end
    end

    describe "GET 'media_library'" do
      it 'should render public index' do
        get :media_library
        expect(flash[:success]).to be_nil
        expect(flash[:error]).to be_nil
        expect(response.status).to eq(200)
        expect(response).to render_template(:media_library)
        expect(assigns('white_papers'.to_sym).first.class.name).to eq('white_papers'.classify)
      end
    end

    describe "GET 'show/1'" do
      it 'should render  show' do
        get :show, white_paper_name_url: white_paper_1.name_url, id: white_paper_1.id
        expect_show_success_with_model('white_paper', white_paper_1.id)
      end
    end

    describe "GET 'new'" do
      it 'should redirect to sign_in' do
        get :new
        expect_new_success_with_model('white_paper')
      end
    end

    describe "GET 'edit/1'" do
      it 'should redirect to sign_in' do
        get :edit, id: 1
        expect_edit_success_with_model('white_paper', white_paper_1.id)
      end
    end

    describe "POST 'create'" do
      it 'should redirect to sign_in' do
        post :create, white_paper: valid_params
        expect_create_success_with_model('white_paper', white_papers_url)
      end
    end

    describe "POST 'create_request'" do
      it 'should report OK for valid params' do
        post :create_request, white_paper_request: request_params
        expect_create_success_with_model('white_paper_request', public_white_paper_url(white_paper_1.name_url))
      end
    end

    describe "PUT 'update/1'" do
      it 'should redirect to sign_in' do
        put :update, id: 1, white_paper: valid_params
        expect_update_success_with_model('white_paper', white_papers_url)
      end
    end

    describe "DELETE 'destroy'" do
      it 'should redirect to sign_in' do
        delete :destroy, id: 1
        expect_delete_success_with_model('white_paper', white_papers_url)
      end
    end

  end

end
