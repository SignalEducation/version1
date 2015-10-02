require 'rails_helper'
require 'support/users_and_groups_setup'

describe CorporateStudentsController, type: :controller do

  include_context 'users_and_groups_setup'

  let!(:corporation_1) { FactoryGirl.create(:corporate_customer) }
  let!(:corporation_2) { FactoryGirl.create(:corporate_customer) }
  let!(:corporate_customer_group) { FactoryGirl.create(:corporate_customer_user_group) }
  let!(:corporate_student_group) { FactoryGirl.create(:corporate_student_user_group) }
  let!(:corporate_customer_user) { FactoryGirl.create(:corporate_customer_user,
                                                     corporate_customer_id: corporation_1.id,
                                                     user_group_id: corporate_customer_group.id)}
  let!(:corporate_student_1) { FactoryGirl.create(:corporate_student_user,
                                                  corporate_customer_id: corporation_1.id,
                                                  user_group_id: corporate_student_group.id) }
  let!(:corporate_student_2) { FactoryGirl.create(:corporate_student_user,
                                                  corporate_customer_id: corporation_1.id,
                                                 user_group_id: corporate_student_group.id) }
  let!(:corporate_student_3) { FactoryGirl.create(:corporate_student_user,
                                                  corporate_customer_id: corporation_2.id,
                                                 user_group_id: corporate_student_group.id) }
  let!(:valid_params) { FactoryGirl.attributes_for(:corporate_student_user) }

  context 'Not logged in: ' do

    describe "GET 'index'" do
      it 'should redirect to sign_in' do
        get :index
        expect_bounce_as_not_signed_in
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
      it 'should respond ERROR not permittedt' do
        get :index
        expect_bounce_as_not_allowed
      end
    end

    describe "GET 'new'" do
      it 'should respond ERROR not permitted' do
        get :new
        expect_bounce_as_not_allowed
      end
    end

    describe "GET 'edit/1'" do
      it 'should respond ERROR not permitted' do
        get :edit, id: corporate_student_1.id
        expect_bounce_as_not_allowed
      end

      # optional
      it 'should respond ERROR not permitted' do
        get :edit, id: corporate_student_2.id
        expect_bounce_as_not_allowed
      end
    end

    describe "POST 'create'" do
      it 'should respond ERROR not permitted' do
        post :create, corporate_student: valid_params
        expect_bounce_as_not_allowed
      end
    end

    describe "PUT 'update/1'" do
      it 'should respond ERROR not permitted' do
        put :update, id: corporate_student_1.id, corporate_student: valid_params
        expect_bounce_as_not_allowed
      end
    end

    describe "DELETE 'destroy'" do
      it 'should respond ERROR not permitted' do
        delete :destroy, id: corporate_student_1.id
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
      it 'should respond ERROR not permitted' do
        get :index
        expect_bounce_as_not_allowed
      end
    end

    describe "GET 'new'" do
      it 'should respond ERROR not permitted' do
        get :new
        expect_bounce_as_not_allowed
      end
    end

    describe "GET 'edit/1'" do
      it 'should respond ERROR not permitted' do
        get :edit, id: corporate_student_1.id
        expect_bounce_as_not_allowed
      end
    end

    describe "POST 'create'" do
      it 'should respond ERROR not permitted' do
        post :create, corporate_student: valid_params
        expect_bounce_as_not_allowed
      end
    end

    describe "PUT 'update/1'" do
      it 'should respond ERROR not permitted' do
        put :update, id: corporate_student_1.id, corporate_student: valid_params
        expect_bounce_as_not_allowed
      end
    end

    describe "DELETE 'destroy'" do
      it 'should respond ERROR not permitted' do
        delete :destroy, id: corporate_student_1.id
        expect_bounce_as_not_allowed
      end
    end

  end

  context 'Logged in as a corporate_student_user: ' do

    before(:each) do
      activate_authlogic
      UserSession.create!(corporate_student_3)
    end

    describe "GET 'index'" do
      it 'should respond ERROR not permitted' do
        get :index
        expect_bounce_as_not_allowed
      end
    end

    describe "GET 'new'" do
      it 'should respond ERROR not permitted' do
        get :new
        expect_bounce_as_not_allowed
      end
    end

    describe "GET 'edit/1'" do
      it 'should respond ERROR not permitted' do
        get :edit, id: corporate_student_1.id
        expect_bounce_as_not_allowed
      end
    end

    describe "POST 'create'" do
      it 'should respond ERROR not permitted' do
        post :create, corporate_student: valid_params
        expect_bounce_as_not_allowed
      end
    end

    describe "PUT 'update/1'" do
      it 'should respond ERROR not permitted' do
        put :update, id: corporate_student_1.id, corporate_student: valid_params
        expect_bounce_as_not_allowed
      end
    end

    describe "DELETE 'destroy'" do
      it 'should respond ERROR not permitted' do
        delete :destroy, id: corporate_student_1.id
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
      it 'should respond OK with students of his corporation' do
        get :index
        expect_index_success_with_model('users', 2, 'corporate_students')
      end
    end

    describe "GET 'new'" do
      it 'should respond OK' do
        get :new
        expect_new_success_with_model('user', 'corporate_student')
      end
    end

    describe "GET 'edit/1'" do
      it 'should respond OK with corporate_student_1' do
        get :edit, id: corporate_student_1.id
        expect_edit_success_with_model('user', corporate_student_1.id, 'corporate_student')
      end

      # optional
      it 'should respond OK with corporate_student_2' do
        get :edit, id: corporate_student_2.id
        expect_edit_success_with_model('user', corporate_student_2.id, 'corporate_student')
      end
    end

    describe "POST 'create'" do
      it 'should report OK for valid params' do
        post :create, corporate_student: valid_params
        expect_create_success_with_model('user', corporate_students_url, nil, 'corporate_student')
        expect(assigns[:corporate_student].password_change_required).to eq(true)
      end

      it 'should report error if email is missing' do
        valid_params.delete(:email)
        post :create, corporate_student: valid_params
        expect(flash[:success]).to be_nil
        expect(response.status).to eq(200)
        expect(assigns('corporate_student'.to_sym).class.name).to eq('user'.classify)
      end
    end

    describe "PUT 'update/1'" do
      it 'should respond OK to valid params for corporate_student_1' do
        put :update, id: corporate_student_1.id, corporate_student: valid_params
        expect_update_success_with_model('user', corporate_students_url, 'corporate_student')
      end

      # optional
      it 'should respond OK to valid params for corporate_student_2' do
        put :update, id: corporate_student_2.id, corporate_student: valid_params
        expect_update_success_with_model('user', corporate_students_url, 'corporate_student')
        expect(assigns(:corporate_student).id).to eq(corporate_student_2.id)
      end

      it 'should reject invalid params' do
        put :update, id: corporate_student_1.id, corporate_student: {valid_params.keys.first => ''}
        expect_update_error_with_model('user', 'corporate_student')
        expect(assigns(:corporate_student).id).to eq(corporate_student_1.id)
      end
    end

    describe "DELETE 'destroy'" do
      it 'should deactivate user' do
        delete :destroy, id: corporate_student_2.id
        expect(flash[:error]).to be_nil
        expect(flash[:success]).to eq(I18n.t("controllers.corporate_students.destroy.flash.success"))
        expect(response.status).to eq(302)
        expect(response).to redirect_to(corporate_students_url)
        expect(assigns(:corporate_student).class.name).to eq('User')
        expect(assigns(:corporate_student).active).to eq(false)
      end
    end

  end

  context 'Logged in as a blogger_user: ' do

    before(:each) do
      activate_authlogic
      UserSession.create!(blogger_user)
    end

    describe "GET 'index'" do
      it 'should respond ERROR not permitted' do
        get :index
        expect_bounce_as_not_allowed
      end
    end

    describe "GET 'new'" do
      it 'should respond ERROR not permitted' do
        get :new
        expect_bounce_as_not_allowed
      end
    end

    describe "GET 'edit/1'" do
      it 'should respond ERROR not permitted' do
        get :edit, id: corporate_student_1.id
        expect_bounce_as_not_allowed
      end
    end

    describe "POST 'create'" do
      it 'should respond ERROR not permitted' do
        post :create, corporate_student: valid_params
        expect_bounce_as_not_allowed
      end
    end

    describe "PUT 'update/1'" do
      it 'should respond ERROR not permitted' do
        put :update, id: corporate_student_1.id, corporate_student: valid_params
        expect_bounce_as_not_allowed
      end
    end

    describe "DELETE 'destroy'" do
      it 'should respond ERROR not permitted' do
        delete :destroy, id: corporate_student_1.id
        expect_bounce_as_not_allowed
      end
    end

  end

  context 'Logged in as a forum_manager_user: ' do

    before(:each) do
      activate_authlogic
      UserSession.create!(forum_manager_user)
    end

    describe "GET 'index'" do
      it 'should respond ERROR not permitted' do
        get :index
        expect_bounce_as_not_allowed
      end
    end

    describe "GET 'new'" do
      it 'should respond ERROR not permitted' do
        get :new
        expect_bounce_as_not_allowed
      end
    end

    describe "GET 'edit/1'" do
      it 'should respond ERROR not permitted' do
        get :edit, id: corporate_student_1.id
        expect_bounce_as_not_allowed
      end
    end

    describe "POST 'create'" do
      it 'should respond ERROR not permitted' do
        post :create, corporate_student: valid_params
        expect_bounce_as_not_allowed
      end
    end

    describe "PUT 'update/1'" do
      it 'should respond ERROR not permitted' do
        put :update, id: corporate_student_1.id, corporate_student: valid_params
        expect_bounce_as_not_allowed
      end
    end

    describe "DELETE 'destroy'" do
      it 'should respond ERROR not permitted' do
        delete :destroy, id: corporate_student_1.id
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
      it 'should respond ERROR not permitted' do
        get :index
        expect_bounce_as_not_allowed
      end
    end

    describe "GET 'new'" do
      it 'should respond ERROR not permitted' do
        get :new
        expect_bounce_as_not_allowed
      end
    end

    describe "GET 'edit/1'" do
      it 'should respond ERROR not permitted' do
        get :edit, id: corporate_student_1.id
        expect_bounce_as_not_allowed
      end
    end

    describe "POST 'create'" do
      it 'should respond ERROR not permitted' do
        post :create, corporate_student: valid_params
        expect_bounce_as_not_allowed
      end
    end

    describe "PUT 'update/1'" do
      it 'should respond ERROR not permitted' do
        put :update, id: corporate_student_1.id, corporate_student: valid_params
        expect_bounce_as_not_allowed
      end
    end

    describe "DELETE 'destroy'" do
      it 'should respond ERROR not permitted' do
        delete :destroy, id: corporate_student_1.id
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
      it 'should respond ERROR not permitted' do
        get :index
        expect_index_success_with_model('users', 3, 'corporate_students')
      end
    end

    describe "GET 'new'" do
      it 'should respond OK' do
        get :new
        expect_new_success_with_model('user', 'corporate_student')
      end
    end

    describe "GET 'edit/1'" do
      it 'should respond OK with corporate_student_1' do
        get :edit, id: corporate_student_1.id
        expect_edit_success_with_model('user', corporate_student_1.id, 'corporate_student')
      end

      # optional
      it 'should respond OK with corporate_student_2' do
        get :edit, id: corporate_student_3.id
        expect_edit_success_with_model('user', corporate_student_3.id, 'corporate_student')
      end
    end

    describe "POST 'create'" do
      it 'should report OK for valid params' do
        post :create, corporate_student: valid_params.merge(corporate_customer_id: corporation_2.id)
        expect_create_success_with_model('user', corporate_students_url, nil, 'corporate_student')
        expect(assigns[:corporate_student].password_change_required).to eq(true)
      end

      it 'should report error if email is missing' do
        valid_params.delete(:email)
        post :create, corporate_student: valid_params
        expect(flash[:success]).to be_nil
        expect(response.status).to eq(200)
        expect(assigns('corporate_student'.to_sym).class.name).to eq('user'.classify)
      end
    end

    describe "PUT 'update/1'" do
      it 'should respond OK to valid params for corporate_student_1' do
        put :update, id: corporate_student_1.id, corporate_student: valid_params
        expect_update_success_with_model('user', corporate_students_url, 'corporate_student')
      end

      # optional
      it 'should respond OK to valid params for corporate_student_2' do
        put :update, id: corporate_student_2.id, corporate_student: valid_params
        expect_update_success_with_model('user', corporate_students_url, 'corporate_student')
        expect(assigns(:corporate_student).id).to eq(corporate_student_2.id)
      end

      it 'should reject invalid params' do
        put :update, id: corporate_student_1.id, corporate_student: {valid_params.keys.first => ''}
        expect_update_error_with_model('user', 'corporate_student')
        expect(assigns(:corporate_student).id).to eq(corporate_student_1.id)
      end
    end

    describe "DELETE 'destroy'" do
      it 'should deactivate user' do
        delete :destroy, id: corporate_student_2.id
        expect(flash[:error]).to be_nil
        expect(flash[:success]).to eq(I18n.t("controllers.corporate_students.destroy.flash.success"))
        expect(response.status).to eq(302)
        expect(response).to redirect_to(corporate_students_url)
        expect(assigns(:corporate_student).class.name).to eq('User')
        expect(assigns(:corporate_student).active).to eq(false)
      end
    end

  end

end
