require 'rails_helper'
require 'support/users_and_groups_setup'

describe UserGroupsController, type: :controller do

  include_context 'users_and_groups_setup'

  let!(:valid_params) { FactoryGirl.attributes_for(:user_group) }

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
        post :create, user_group: valid_params
        expect(response.status).to eq(302)
        expect(response).to redirect_to(root_url)
        expect(flash[:error]).to eq(I18n.t('controllers.application.logged_in_required.flash_error'))
      end
    end

    describe "PUT 'update/1'" do
      it 'should redirect to root' do
        put :update, id: 1, user_group: valid_params
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

  context 'Logged in as a individual_student_user' do

    before(:each) do
      activate_authlogic
      UserSession.create!(individual_student_user)
    end

    describe "GET 'index'" do
      it 'should redirect to root' do
        get :index
        expect(response.status).to eq(302)
        expect(response).to redirect_to(root_url)
        expect(flash[:error]).to eq(I18n.t('controllers.application.you_are_not_permitted_to_do_that'))
      end
    end

    describe "GET 'show/1'" do
      it 'should redirect to root' do
        get :show, id: 1
        expect(response.status).to eq(302)
        expect(response).to redirect_to(root_url)
        expect(flash[:error]).to eq(I18n.t('controllers.application.you_are_not_permitted_to_do_that'))
      end
    end

    describe "GET 'new'" do
      it 'should redirect to root' do
        get :new
        expect(response.status).to eq(302)
        expect(response).to redirect_to(root_url)
        expect(flash[:error]).to eq(I18n.t('controllers.application.you_are_not_permitted_to_do_that'))
      end
    end

    describe "GET 'edit/1'" do
      it 'should redirect to root' do
        get :edit, id: 1
        expect(response.status).to eq(302)
        expect(response).to redirect_to(root_url)
        expect(flash[:error]).to eq(I18n.t('controllers.application.you_are_not_permitted_to_do_that'))
      end
    end

    describe "POST 'create'" do
      it 'should redirect to root' do
        post :create, user_group: valid_params
        expect(response.status).to eq(302)
        expect(response).to redirect_to(root_url)
        expect(flash[:error]).to eq(I18n.t('controllers.application.you_are_not_permitted_to_do_that'))
      end
    end

    describe "PUT 'update/1'" do
      it 'should redirect to root' do
        put :update, id: 1, user_group: valid_params
        expect(response.status).to eq(302)
        expect(response).to redirect_to(root_url)
        expect(flash[:error]).to eq(I18n.t('controllers.application.you_are_not_permitted_to_do_that'))
      end
    end

    describe "DELETE 'destroy'" do
      it 'should redirect to root' do
        delete :destroy, id: 1
        expect(response.status).to eq(302)
        expect(response).to redirect_to(root_url)
        expect(flash[:error]).to eq(I18n.t('controllers.application.you_are_not_permitted_to_do_that'))
      end
    end

  end

  context 'Logged in as a corporate_student_user' do

    before(:each) do
      activate_authlogic
      UserSession.create!(corporate_student_user)
    end

    describe "GET 'index'" do
      it 'should redirect to root' do
        get :index
        expect(response.status).to eq(302)
        expect(response).to redirect_to(root_url)
        expect(flash[:error]).to eq(I18n.t('controllers.application.you_are_not_permitted_to_do_that'))
      end
    end

    describe "GET 'show/1'" do
      it 'should redirect to root' do
        get :show, id: 1
        expect(response.status).to eq(302)
        expect(response).to redirect_to(root_url)
        expect(flash[:error]).to eq(I18n.t('controllers.application.you_are_not_permitted_to_do_that'))
      end
    end

    describe "GET 'new'" do
      it 'should redirect to root' do
        get :new
        expect(response.status).to eq(302)
        expect(response).to redirect_to(root_url)
        expect(flash[:error]).to eq(I18n.t('controllers.application.you_are_not_permitted_to_do_that'))
      end
    end

    describe "GET 'edit/1'" do
      it 'should redirect to root' do
        get :edit, id: 1
        expect(response.status).to eq(302)
        expect(response).to redirect_to(root_url)
        expect(flash[:error]).to eq(I18n.t('controllers.application.you_are_not_permitted_to_do_that'))
      end
    end

    describe "POST 'create'" do
      it 'should redirect to root' do
        post :create, user_group: valid_params
        expect(response.status).to eq(302)
        expect(response).to redirect_to(root_url)
        expect(flash[:error]).to eq(I18n.t('controllers.application.you_are_not_permitted_to_do_that'))
      end
    end

    describe "PUT 'update/1'" do
      it 'should redirect to root' do
        put :update, id: 1, user_group: valid_params
        expect(response.status).to eq(302)
        expect(response).to redirect_to(root_url)
        expect(flash[:error]).to eq(I18n.t('controllers.application.you_are_not_permitted_to_do_that'))
      end
    end

    describe "DELETE 'destroy'" do
      it 'should redirect to root' do
        delete :destroy, id: 1
        expect(response.status).to eq(302)
        expect(response).to redirect_to(root_url)
        expect(flash[:error]).to eq(I18n.t('controllers.application.you_are_not_permitted_to_do_that'))
      end
    end

  end

  context 'Logged in as a tutor_user' do

    before(:each) do
      activate_authlogic
      UserSession.create!(tutor_user)
    end

    describe "GET 'index'" do
      it 'should redirect to root' do
        get :index
        expect(response.status).to eq(302)
        expect(response).to redirect_to(root_url)
        expect(flash[:error]).to eq(I18n.t('controllers.application.you_are_not_permitted_to_do_that'))
      end
    end

    describe "GET 'show/1'" do
      it 'should redirect to root' do
        get :show, id: 1
        expect(response.status).to eq(302)
        expect(response).to redirect_to(root_url)
        expect(flash[:error]).to eq(I18n.t('controllers.application.you_are_not_permitted_to_do_that'))
      end
    end

    describe "GET 'new'" do
      it 'should redirect to root' do
        get :new
        expect(response.status).to eq(302)
        expect(response).to redirect_to(root_url)
        expect(flash[:error]).to eq(I18n.t('controllers.application.you_are_not_permitted_to_do_that'))
      end
    end

    describe "GET 'edit/1'" do
      it 'should redirect to root' do
        get :edit, id: 1
        expect(response.status).to eq(302)
        expect(response).to redirect_to(root_url)
        expect(flash[:error]).to eq(I18n.t('controllers.application.you_are_not_permitted_to_do_that'))
      end
    end

    describe "POST 'create'" do
      it 'should redirect to root' do
        post :create, user_group: valid_params
        expect(response.status).to eq(302)
        expect(response).to redirect_to(root_url)
        expect(flash[:error]).to eq(I18n.t('controllers.application.you_are_not_permitted_to_do_that'))
      end
    end

    describe "PUT 'update/1'" do
      it 'should redirect to root' do
        put :update, id: 1, user_group: valid_params
        expect(response.status).to eq(302)
        expect(response).to redirect_to(root_url)
        expect(flash[:error]).to eq(I18n.t('controllers.application.you_are_not_permitted_to_do_that'))
      end
    end

    describe "DELETE 'destroy'" do
      it 'should redirect to root' do
        delete :destroy, id: 1
        expect(response.status).to eq(302)
        expect(response).to redirect_to(root_url)
        expect(flash[:error]).to eq(I18n.t('controllers.application.you_are_not_permitted_to_do_that'))
      end
    end

  end

  context 'Logged in as a corporate_customer_user' do

    before(:each) do
      activate_authlogic
      UserSession.create!(corporate_customer_user)
    end

    describe "GET 'index'" do
      it 'should redirect to root' do
        get :index
        expect(response.status).to eq(302)
        expect(response).to redirect_to(root_url)
        expect(flash[:error]).to eq(I18n.t('controllers.application.you_are_not_permitted_to_do_that'))
      end
    end

    describe "GET 'show/1'" do
      it 'should redirect to root' do
        get :show, id: 1
        expect(response.status).to eq(302)
        expect(response).to redirect_to(root_url)
        expect(flash[:error]).to eq(I18n.t('controllers.application.you_are_not_permitted_to_do_that'))
      end
    end

    describe "GET 'new'" do
      it 'should redirect to root' do
        get :new
        expect(response.status).to eq(302)
        expect(response).to redirect_to(root_url)
        expect(flash[:error]).to eq(I18n.t('controllers.application.you_are_not_permitted_to_do_that'))
      end
    end

    describe "GET 'edit/1'" do
      it 'should redirect to root' do
        get :edit, id: 1
        expect(response.status).to eq(302)
        expect(response).to redirect_to(root_url)
        expect(flash[:error]).to eq(I18n.t('controllers.application.you_are_not_permitted_to_do_that'))
      end
    end

    describe "POST 'create'" do
      it 'should redirect to root' do
        post :create, user_group: valid_params
        expect(response.status).to eq(302)
        expect(response).to redirect_to(root_url)
        expect(flash[:error]).to eq(I18n.t('controllers.application.you_are_not_permitted_to_do_that'))
      end
    end

    describe "PUT 'update/1'" do
      it 'should redirect to root' do
        put :update, id: 1, user_group: valid_params
        expect(response.status).to eq(302)
        expect(response).to redirect_to(root_url)
        expect(flash[:error]).to eq(I18n.t('controllers.application.you_are_not_permitted_to_do_that'))
      end
    end

    describe "DELETE 'destroy'" do
      it 'should redirect to root' do
        delete :destroy, id: 1
        expect(response.status).to eq(302)
        expect(response).to redirect_to(root_url)
        expect(flash[:error]).to eq(I18n.t('controllers.application.you_are_not_permitted_to_do_that'))
      end
    end

  end

  context 'Logged in as a blogger_user' do

    before(:each) do
      activate_authlogic
      UserSession.create!(blogger_user)
    end

    describe "GET 'index'" do
      it 'should redirect to root' do
        get :index
        expect(response.status).to eq(302)
        expect(response).to redirect_to(root_url)
        expect(flash[:error]).to eq(I18n.t('controllers.application.you_are_not_permitted_to_do_that'))
      end
    end

    describe "GET 'show/1'" do
      it 'should redirect to root' do
        get :show, id: 1
        expect(response.status).to eq(302)
        expect(response).to redirect_to(root_url)
        expect(flash[:error]).to eq(I18n.t('controllers.application.you_are_not_permitted_to_do_that'))
      end
    end

    describe "GET 'new'" do
      it 'should redirect to root' do
        get :new
        expect(response.status).to eq(302)
        expect(response).to redirect_to(root_url)
        expect(flash[:error]).to eq(I18n.t('controllers.application.you_are_not_permitted_to_do_that'))
      end
    end

    describe "GET 'edit/1'" do
      it 'should redirect to root' do
        get :edit, id: 1
        expect(response.status).to eq(302)
        expect(response).to redirect_to(root_url)
        expect(flash[:error]).to eq(I18n.t('controllers.application.you_are_not_permitted_to_do_that'))
      end
    end

    describe "POST 'create'" do
      it 'should redirect to root' do
        post :create, user_group: valid_params
        expect(response.status).to eq(302)
        expect(response).to redirect_to(root_url)
        expect(flash[:error]).to eq(I18n.t('controllers.application.you_are_not_permitted_to_do_that'))
      end
    end

    describe "PUT 'update/1'" do
      it 'should redirect to root' do
        put :update, id: 1, user_group: valid_params
        expect(response.status).to eq(302)
        expect(response).to redirect_to(root_url)
        expect(flash[:error]).to eq(I18n.t('controllers.application.you_are_not_permitted_to_do_that'))
      end
    end

    describe "DELETE 'destroy'" do
      it 'should redirect to root' do
        delete :destroy, id: 1
        expect(response.status).to eq(302)
        expect(response).to redirect_to(root_url)
        expect(flash[:error]).to eq(I18n.t('controllers.application.you_are_not_permitted_to_do_that'))
      end
    end

  end

  context 'Logged in as a forum_manager_user' do

    before(:each) do
      activate_authlogic
      UserSession.create!(forum_manager_user)
    end

    describe "GET 'index'" do
      it 'should redirect to root' do
        get :index
        expect(response.status).to eq(302)
        expect(response).to redirect_to(root_url)
        expect(flash[:error]).to eq(I18n.t('controllers.application.you_are_not_permitted_to_do_that'))
      end
    end

    describe "GET 'show/1'" do
      it 'should redirect to root' do
        get :show, id: 1
        expect(response.status).to eq(302)
        expect(response).to redirect_to(root_url)
        expect(flash[:error]).to eq(I18n.t('controllers.application.you_are_not_permitted_to_do_that'))
      end
    end

    describe "GET 'new'" do
      it 'should redirect to root' do
        get :new
        expect(response.status).to eq(302)
        expect(response).to redirect_to(root_url)
        expect(flash[:error]).to eq(I18n.t('controllers.application.you_are_not_permitted_to_do_that'))
      end
    end

    describe "GET 'edit/1'" do
      it 'should redirect to root' do
        get :edit, id: 1
        expect(response.status).to eq(302)
        expect(response).to redirect_to(root_url)
        expect(flash[:error]).to eq(I18n.t('controllers.application.you_are_not_permitted_to_do_that'))
      end
    end

    describe "POST 'create'" do
      it 'should redirect to root' do
        post :create, user_group: valid_params
        expect(response.status).to eq(302)
        expect(response).to redirect_to(root_url)
        expect(flash[:error]).to eq(I18n.t('controllers.application.you_are_not_permitted_to_do_that'))
      end
    end

    describe "PUT 'update/1'" do
      it 'should redirect to root' do
        put :update, id: 1, user_group: valid_params
        expect(response.status).to eq(302)
        expect(response).to redirect_to(root_url)
        expect(flash[:error]).to eq(I18n.t('controllers.application.you_are_not_permitted_to_do_that'))
      end
    end

    describe "DELETE 'destroy'" do
      it 'should redirect to root' do
        delete :destroy, id: 1
        expect(response.status).to eq(302)
        expect(response).to redirect_to(root_url)
        expect(flash[:error]).to eq(I18n.t('controllers.application.you_are_not_permitted_to_do_that'))
      end
    end

  end

  context 'Logged in as a content_manager_user' do

    before(:each) do
      activate_authlogic
      UserSession.create!(content_manager_user)
    end

    describe "GET 'index'" do
      it 'should redirect to root' do
        get :index
        expect(response.status).to eq(302)
        expect(response).to redirect_to(root_url)
        expect(flash[:error]).to eq(I18n.t('controllers.application.you_are_not_permitted_to_do_that'))
      end
    end

    describe "GET 'show/1'" do
      it 'should redirect to root' do
        get :show, id: 1
        expect(response.status).to eq(302)
        expect(response).to redirect_to(root_url)
        expect(flash[:error]).to eq(I18n.t('controllers.application.you_are_not_permitted_to_do_that'))
      end
    end

    describe "GET 'new'" do
      it 'should redirect to root' do
        get :new
        expect(response.status).to eq(302)
        expect(response).to redirect_to(root_url)
        expect(flash[:error]).to eq(I18n.t('controllers.application.you_are_not_permitted_to_do_that'))
      end
    end

    describe "GET 'edit/1'" do
      it 'should redirect to root' do
        get :edit, id: 1
        expect(response.status).to eq(302)
        expect(response).to redirect_to(root_url)
        expect(flash[:error]).to eq(I18n.t('controllers.application.you_are_not_permitted_to_do_that'))
      end
    end

    describe "POST 'create'" do
      it 'should redirect to root' do
        post :create, user_group: valid_params
        expect(response.status).to eq(302)
        expect(response).to redirect_to(root_url)
        expect(flash[:error]).to eq(I18n.t('controllers.application.you_are_not_permitted_to_do_that'))
      end
    end

    describe "PUT 'update/1'" do
      it 'should redirect to root' do
        put :update, id: 1, user_group: valid_params
        expect(response.status).to eq(302)
        expect(response).to redirect_to(root_url)
        expect(flash[:error]).to eq(I18n.t('controllers.application.you_are_not_permitted_to_do_that'))
      end
    end

    describe "DELETE 'destroy'" do
      it 'should redirect to root' do
        delete :destroy, id: 1
        expect(response.status).to eq(302)
        expect(response).to redirect_to(root_url)
        expect(flash[:error]).to eq(I18n.t('controllers.application.you_are_not_permitted_to_do_that'))
      end
    end

  end

  context 'Logged in as a admin_user' do

    before(:each) do
      activate_authlogic
      UserSession.create!(admin_user)
    end

    describe "GET 'index'" do
      it 'should respond with OK' do
        get :index
        expect(response.status).to eq(200)
        expect(response).to render_template(:index)
        expect(flash[:error]).to be_nil
        expect(flash[:success]).to be_nil
        expect(assigns(:user_groups).first.class).to eq(UserGroup)
      end
    end

    describe "GET 'show/1'" do
      it 'should respond with OK' do
        get :show, id: individual_student_user_group.id
        expect(response.status).to eq(200)
        expect(response).to render_template(:show)
        expect(flash[:error]).to be_nil
        expect(flash[:success]).to be_nil
        expect(assigns(:user_group).class).to eq(UserGroup)
      end
    end

    describe "GET 'new'" do
      it 'should respond with OK' do
        get :new
        expect(response.status).to eq(200)
        expect(response).to render_template(:new)
        expect(flash[:error]).to be_nil
        expect(flash[:success]).to be_nil
        expect(assigns(:user_group).class).to eq(UserGroup)
      end
    end

    describe "GET 'edit/1'" do
      it 'should respond with OK' do
        get :edit, id: individual_student_user_group.id
        expect(response.status).to eq(200)
        expect(response).to render_template(:edit)
        expect(flash[:error]).to be_nil
        expect(flash[:success]).to be_nil
        expect(assigns(:user_group).class).to eq(UserGroup)
      end
    end

    describe "POST 'create'" do
      it 'should respond with OK to good input' do
        post :create, user_group: valid_params
        expect(response.status).to eq(302)
        expect(response).to redirect_to(user_groups_url)
        expect(flash[:error]).to be_nil
        expect(flash[:success]).to eq(I18n.t('controllers.user_groups.create.flash.success'))
      end

      it 'should reload the form for bad input' do
        post :create, user_group: {name: '', description: ''}
        expect(response.status).to eq(200)
        expect(response).to render_template(:new)
        expect(flash[:error]).to be_nil
        expect(flash[:success]).to be_nil
        expect(assigns(:user_group).class).to eq(UserGroup)
      end
    end

    describe "PUT 'update/1'" do
      it 'should respond OK to valid input' do
        put :update, id: individual_student_user_group.id, user_group: valid_params
        expect(response.status).to eq(302)
        expect(response).to redirect_to(user_groups_url)
        expect(flash[:error]).to be_nil
        expect(flash[:success]).to eq(I18n.t('controllers.user_groups.update.flash.success'))
      end

      it 'should reload the edit page on invalid input' do
        put :update, id: individual_student_user_group.id, user_group: {name: ''}
        expect(response.status).to eq(200)
        expect(response).to render_template(:edit)
        expect(flash[:error]).to be_nil
        expect(flash[:success]).to be_nil
        expect(assigns(:user_group).class).to eq(UserGroup)
      end
    end

    describe "DELETE 'destroy'" do
      it 'should allow the deletion as dependant has been deleted too' do
        individual_student_user_group.users.destroy_all
        delete :destroy, id: individual_student_user_group.id
        expect(response.status).to eq(302)
        expect(response).to redirect_to(user_groups_url)
        expect(flash[:error]).to be_nil
        expect(flash[:success]).to eq(I18n.t('controllers.user_groups.destroy.flash.success'))
      end

      it 'should fail to delete as dependant exists' do
        delete :destroy, id: individual_student_user_group.id
        expect(response.status).to eq(302)
        expect(response).to redirect_to(user_groups_url)
        expect(flash[:error]).to eq(I18n.t('controllers.user_groups.destroy.flash.error'))
        expect(flash[:success]).to be_nil
      end
    end

  end

end
