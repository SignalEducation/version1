<%- @user_types = %w(individual_student tutor corporate_student corporate_customer blogger forum_manager content_manager admin) -%>
require 'rails_helper'

describe <%= table_name.camelcase -%>Controller, type: :controller do

  let!(:valid_params) { { name: 'Lorem ipsum' } }

  context 'Not logged in...' do

    describe "GET 'index'" do
      it 'should redirect to root' do
        get :index
        expect(response.status).to eq(302)
        expect(response).to redirect_to(root_url)
        expect(flash[:error]).to eq(I18n.t('controllers.application.logged_in_required.flash_error'))
      end
    end

    describe "GET 'show/1'" do
      it 'should redirect to root' do
        get :show, id: 1
        expect(response.status).to eq(302)
        expect(response).to redirect_to(root_url)
        expect(flash[:error]).to eq(I18n.t('controllers.application.logged_in_required.flash_error'))
      end
    end

    describe "GET 'new'" do
      it 'should redirect to root' do
        get :new
        expect(response.status).to eq(302)
        expect(response).to redirect_to(root_url)
        expect(flash[:error]).to eq(I18n.t('controllers.application.logged_in_required.flash_error'))
      end
    end

    describe "GET 'edit/1'" do
      it 'should redirect to root' do
        get :edit, id: 1
        expect(response.status).to eq(302)
        expect(response).to redirect_to(root_url)
        expect(flash[:error]).to eq(I18n.t('controllers.application.logged_in_required.flash_error'))
      end
    end

    describe "POST 'create'" do
      it 'should redirect to root' do
        post :create, <%= singular_table_name -%>: valid_params
        expect(response.status).to eq(302)
        expect(response).to redirect_to(root_url)
        expect(flash[:error]).to eq(I18n.t('controllers.application.logged_in_required.flash_error'))
      end
    end

    describe "PUT 'update/1'" do
      it 'should redirect to root' do
        put :update, id: 1, <%= singular_table_name -%>: valid_params
        expect(response.status).to eq(302)
        expect(response).to redirect_to(root_url)
        expect(flash[:error]).to eq(I18n.t('controllers.application.logged_in_required.flash_error'))
      end
    end

    describe "DELETE 'destroy'" do
      it 'should redirect to root' do
        delete :destroy, id: 1
        expect(response.status).to eq(302)
        expect(response).to redirect_to(root_url)
        expect(flash[:error]).to eq(I18n.t('controllers.application.logged_in_required.flash_error'))
      end
    end

  end

  context 'Logged in as nothing special...' do

  end

  <%- @user_types.each do |user_type| -%>
  context 'Logged in as a <%= user_type -%>_user' do
    pending
  end

  <%- end -%>

end
