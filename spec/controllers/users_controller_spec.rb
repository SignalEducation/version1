# == Schema Information
#
# Table name: users
#
#  id                               :integer          not null, primary key
#  email                            :string
#  first_name                       :string
#  last_name                        :string
#  address                          :text
#  country_id                       :integer
#  crypted_password                 :string(128)      default(""), not null
#  password_salt                    :string(128)      default(""), not null
#  persistence_token                :string
#  perishable_token                 :string(128)
#  single_access_token              :string
#  login_count                      :integer          default(0)
#  failed_login_count               :integer          default(0)
#  last_request_at                  :datetime
#  current_login_at                 :datetime
#  last_login_at                    :datetime
#  current_login_ip                 :string
#  last_login_ip                    :string
#  account_activation_code          :string
#  account_activated_at             :datetime
#  active                           :boolean          default(FALSE), not null
#  user_group_id                    :integer
#  password_reset_requested_at      :datetime
#  password_reset_token             :string
#  password_reset_at                :datetime
#  stripe_customer_id               :string
#  created_at                       :datetime
#  updated_at                       :datetime
#  locale                           :string
#  guid                             :string
#  trial_ended_notification_sent_at :datetime
#  crush_offers_session_id          :string
#  subscription_plan_category_id    :integer
#  password_change_required         :boolean
#  session_key                      :string
#  name_url                         :string
#  profile_image_file_name          :string
#  profile_image_content_type       :string
#  profile_image_file_size          :integer
#  profile_image_updated_at         :datetime
#  topic_interest                   :string
#  email_verification_code          :string
#  email_verified_at                :datetime
#  email_verified                   :boolean          default(FALSE), not null
#  stripe_account_balance           :integer          default(0)
#  trial_limit_in_seconds           :integer          default(0)
#  free_trial                       :boolean          default(FALSE)
#  trial_limit_in_days              :integer          default(0)
#  terms_and_conditions             :boolean          default(FALSE)
#  discourse_user                   :boolean          default(FALSE)
#  date_of_birth                    :date
#  description                      :text
#  free_trial_ended_at              :datetime
#  analytics_guid                   :string
#  forum_username                   :string
#

require 'rails_helper'
require 'support/users_and_groups_setup'

describe UsersController, type: :controller do

  include_context 'users_and_groups_setup'

  let!(:country_1) { FactoryGirl.create(:uk) }
  let!(:country_2) { FactoryGirl.create(:ireland) }
  let!(:country_3) { FactoryGirl.create(:usa) }
  let!(:upgrading_user) { FactoryGirl.create(:individual_student_user) }
  let!(:valid_params) { FactoryGirl.attributes_for(:individual_student_user, user_group_id: individual_student_user_group.id) }

  context 'Not logged in...' do

    describe "GET 'index'" do
      it 'should redirect to root' do
        get :index
        expect_bounce_as_not_signed_in
      end
    end

    describe "GET 'show/1'" do
      it 'should redirect to root' do
        get :show, id: 1
        expect_bounce_as_not_signed_in
      end
    end

    describe "GET 'new'" do
      it 'should redirect to root' do
        get :new
        expect_bounce_as_not_signed_in
      end
    end

    describe "GET 'edit/1'" do
      it 'should redirect to root' do
        get :edit, id: 1
        expect_bounce_as_not_signed_in
      end
    end

    describe "POST 'create'" do
      it 'should redirect to root' do
        post :create, user: valid_params
        expect_bounce_as_not_signed_in
      end
    end

    describe "PUT 'update/1'" do
      it 'should redirect to root' do
        put :update, id: 1, user: valid_params
        expect_bounce_as_not_signed_in
      end
    end

    describe "DELETE 'destroy'" do
      it 'should redirect to root' do
        delete :destroy, id: 1
        expect_bounce_as_not_signed_in
      end
    end

    describe "POST 'change_password'" do
      it 'should redirect to root' do
        post :change_password
        expect_bounce_as_not_signed_in
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
        expect_bounce_as_not_allowed
      end
    end

    describe "GET 'show/1'" do
      it 'should redirect to root' do
        get :show, id: individual_student_user.id
        expect_bounce_as_not_allowed
      end

    end

    describe "GET account" do
      it 'should see my own profile' do
        get :account, id: individual_student_user.id
        expect(flash[:success]).to be_nil
        expect(flash[:error]).to be_nil
        expect(response.status).to eq(200)
        expect(response).to render_template(:account)
      end
    end

    describe "GET 'new'" do
      it 'should redirect to root' do
        get :new
        expect_bounce_as_not_allowed
      end
    end

    describe "GET 'edit/1'" do
      it 'should redirect to root' do
        get :edit, id: individual_student_user.id
        expect_bounce_as_not_allowed
      end
    end

    describe "POST 'create'" do
      it 'should redirect to root' do
        post :create, user: valid_params
        expect_bounce_as_not_allowed
      end
    end

    describe "PUT 'update/1'" do
      it 'should respond OK to valid params' do
        put :update, id: individual_student_user.id, user: valid_params
        expect_update_success_with_model('user', account_url)
        expect(assigns(:user).id).to eq(individual_student_user.id)
      end

      it 'should respond OK to valid params and insist on their own user ID being updated' do
        put :update, id: admin_user.id, user: valid_params
        expect_update_success_with_model('user', account_url)
        expect(assigns(:user).id).to eq(individual_student_user.id)
      end

      it 'should reject invalid params' do
        put :update, id: individual_student_user.id, user: {email: 'a'}
        expect(flash[:success]).to be_nil
        expect(flash[:error]).to be_nil
        expect(response.status).to eq(302)
        expect(response).to redirect_to(account_url(anchor: 'personal-details-modal'))
      end
    end

    describe "DELETE 'destroy'" do
      it 'should redirect to root' do
        delete :destroy, id: 1
        expect_bounce_as_not_allowed
      end
    end

    describe "POST: 'change_password'" do
      it 'should respond OK to correct details' do
        post :change_password, user: {current_password: 'letSomeone1n', password: '456456456', password_confirmation: '456456456'}
        expect_change_password_success_with_model(account_url)
      end

      it 'should respond ERROR to incorrect details' do
        post :change_password, user: {current_password: 'oops', password: '456456456', password_confirmation: '456456456'}
        expect_change_password_error_with_model(account_url)
      end
    end

  end

  context 'Logged in as a comp_user' do

    before(:each) do
      activate_authlogic
      UserSession.create!(comp_user)
    end

    describe "GET 'index'" do
      it 'should redirect to root' do
        get :index
        expect_bounce_as_not_allowed
      end
    end

    describe "GET account" do
      it 'should render account page' do
        get :account, id: comp_user.id
        expect(flash[:success]).to be_nil
        expect(flash[:error]).to be_nil
        expect(response.status).to eq(200)
        expect(response).to render_template(:account)
      end
    end

    describe "GET 'show/1'" do
      it 'should redirect to root' do
        get :show, id: comp_user.id
        expect_bounce_as_not_allowed
      end
    end

    describe "GET 'new'" do
      it 'should redirect to root' do
        get :new
        expect_bounce_as_not_allowed
      end
    end

    describe "GET 'edit/1'" do
      it 'should respond with not allowed' do
        get :edit, id: comp_user.id
        expect_bounce_as_not_allowed
      end
    end

    describe "POST 'create'" do
      it 'should redirect to root' do
        post :create, user: valid_params
        expect_bounce_as_not_allowed
      end
    end

    describe "PUT 'update/1'" do
      it 'should respond OK to valid params' do
        put :update, id: comp_user.id, user: valid_params
        expect_update_success_with_model('user', account_url)
        expect(assigns(:user).id).to eq(comp_user.id)
      end

      it 'should respond OK to valid params and insist on their own user ID being updated' do
        put :update, id: admin_user.id, user: valid_params
        expect_update_success_with_model('user', account_url)
        expect(assigns(:user).id).to eq(comp_user.id)
      end

      it 'should reject invalid params' do
        put :update, id: comp_user.id, user: {email: 'a'}
        expect(flash[:success]).to be_nil
        expect(flash[:error]).to be_nil
        expect(response.status).to eq(302)
        expect(response).to redirect_to(account_url(anchor: 'personal-details-modal'))

      end
    end

    describe "DELETE 'destroy'" do
      it 'should redirect to root' do
        delete :destroy, id: 1
        expect_bounce_as_not_allowed
      end
    end

    describe "POST: 'change_password'" do
      it 'should respond OK to correct details' do
        post :change_password, user: {current_password: 'letSomeone1n', password: '456456456', password_confirmation: '456456456'}
        expect_change_password_success_with_model(account_url)
      end

      it 'should respond ERROR to incorrect details' do
        post :change_password, user: {current_password: 'oops', password: '456456456', password_confirmation: '456456456'}
        expect_change_password_error_with_model(account_url)
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
        expect_bounce_as_not_allowed
      end
    end

    describe "GET 'show/1'" do
      it 'should see my own profile' do
        get :show, id: tutor_user.id
        expect_bounce_as_not_allowed
      end

      it 'should see my own profile even if I ask for another' do
        get :show, id: admin_user.id
        expect_bounce_as_not_allowed
      end
    end

    describe "GET account" do
      it 'should see my own profile' do
        get :account, id: tutor_user.id
        expect(flash[:success]).to be_nil
        expect(flash[:error]).to be_nil
        expect(response.status).to eq(200)
        expect(response).to render_template(:account)
      end

    end

    describe "GET 'new'" do
      it 'should redirect to root' do
        get :new
        expect_bounce_as_not_allowed
      end
    end

    describe "GET 'edit/1'" do
      it 'should respond with OK' do
        get :edit, id: tutor_user.id
        expect_bounce_as_not_allowed
      end

      it 'should only allow editing of own user' do
        get :edit, id: admin_user.id
        expect_bounce_as_not_allowed
      end
    end

    describe "POST 'create'" do
      it 'should redirect to root' do
        post :create, user: valid_params
        expect_bounce_as_not_allowed
      end
    end

    describe "PUT 'update/1'" do
      it 'should respond OK to valid params' do
        put :update, id: tutor_user.id, user: valid_params
        expect_update_success_with_model('user', account_url)
        expect(assigns(:user).id).to eq(tutor_user.id)
      end

      it 'should respond OK to valid params and insist on their own user ID being updated' do
        put :update, id: admin_user.id, user: valid_params
        expect_update_success_with_model('user', account_url)
        expect(assigns(:user).id).to eq(tutor_user.id)
      end

      it 'should reject invalid params' do
        put :update, id: tutor_user.id, user: {email: 'a'}
        expect(flash[:success]).to be_nil
        expect(flash[:error]).to be_nil
        expect(response.status).to eq(302)
        expect(response).to redirect_to(account_url(anchor: 'personal-details-modal'))
      end
    end

    describe "DELETE 'destroy'" do
      it 'should redirect to root' do
        delete :destroy, id: 1
        expect_bounce_as_not_allowed
      end
    end

    describe "POST: 'change_password'" do
      it 'should respond OK to correct details' do
        post :change_password, user: {current_password: 'letSomeone1n', password: '456456456', password_confirmation: '456456456'}
        expect_change_password_success_with_model(account_url)
      end

      it 'should respond ERROR to incorrect details' do
        post :change_password, user: {current_password: 'oops', password: '456456456', password_confirmation: '456456456'}
        expect_change_password_error_with_model(account_url)
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
        expect_bounce_as_not_allowed
      end
    end

    describe "GET 'show/1'" do
      it 'should see my own profile' do
        get :show, id: blogger_user.id
        expect_bounce_as_not_allowed
      end

      it 'should see my own profile even if I ask for another' do
        get :show, id: admin_user.id
        expect_bounce_as_not_allowed
      end
    end

    describe "GET account" do
      it 'should see my own profile' do
        get :account, id: blogger_user.id
        expect(flash[:success]).to be_nil
        expect(flash[:error]).to be_nil
        expect(response.status).to eq(200)
        expect(response).to render_template(:account)
      end
    end

    describe "GET 'new'" do
      it 'should redirect to root' do
        get :new
        expect_bounce_as_not_allowed
      end
    end

    describe "GET 'edit/1'" do
      it 'should respond with OK' do
        get :edit, id: blogger_user.id
        expect_bounce_as_not_allowed
      end

      it 'should only allow editing of own user' do
        get :edit, id: admin_user.id
        expect_bounce_as_not_allowed
      end
    end

    describe "POST 'create'" do
      it 'should redirect to root' do
        post :create, user: valid_params
        expect_bounce_as_not_allowed
      end
    end

    describe "PUT 'update/1'" do
      it 'should respond OK to valid params' do
        put :update, id: blogger_user.id, user: valid_params
        expect_update_success_with_model('user', account_url)
        expect(assigns(:user).id).to eq(blogger_user.id)
      end

      it 'should respond OK to valid params and insist on their own user ID being updated' do
        put :update, id: admin_user.id, user: valid_params
        expect_update_success_with_model('user', account_url)
        expect(assigns(:user).id).to eq(blogger_user.id)
      end

      it 'should reject invalid params' do
        put :update, id: blogger_user.id, user: {email: 'a'}
        expect(flash[:success]).to be_nil
        expect(flash[:error]).to be_nil
        expect(response.status).to eq(302)
        expect(response).to redirect_to(account_url(anchor: 'personal-details-modal'))
      end
    end

    describe "DELETE 'destroy'" do
      it 'should redirect to root' do
        delete :destroy, id: 1
        expect_bounce_as_not_allowed
      end
    end

    describe "POST: 'change_password'" do
      it 'should respond OK to correct details' do
        post :change_password, user: {current_password: 'letSomeone1n', password: '456456456', password_confirmation: '456456456'}
        expect_change_password_success_with_model(account_url)
      end

      it 'should respond ERROR to incorrect details' do
        post :change_password, user: {current_password: 'oops', password: '456456456', password_confirmation: '456456456'}
        expect_change_password_error_with_model(account_url)
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
        expect_bounce_as_not_allowed
      end
    end

    describe "GET 'show/1'" do
      it 'should see my own profile' do
        get :show, id: content_manager_user.id
        expect_bounce_as_not_allowed
      end

      it 'should see my own profile even if I ask for another' do
        get :show, id: admin_user.id
        expect_bounce_as_not_allowed
      end
    end

    describe "GET account" do
      it 'should see my own profile' do
        get :account, id: content_manager_user.id
        expect(flash[:success]).to be_nil
        expect(flash[:error]).to be_nil
        expect(response.status).to eq(200)
        expect(response).to render_template(:account)
      end
    end

    describe "GET 'new'" do
      it 'should redirect to root' do
        get :new
        expect_bounce_as_not_allowed
      end
    end

    describe "GET 'edit/1'" do
      it 'should respond with OK' do
        get :edit, id: content_manager_user.id
        expect_bounce_as_not_allowed
      end

      it 'should only allow editing of own user' do
        get :edit, id: admin_user.id
        expect_bounce_as_not_allowed
      end
    end

    describe "POST 'create'" do
      it 'should redirect to root' do
        post :create, user: valid_params
        expect_bounce_as_not_allowed
      end
    end

    describe "PUT 'update/1'" do
      it 'should respond OK to valid params' do
        put :update, id: content_manager_user.id, user: valid_params
        expect_update_success_with_model('user', account_url)
        expect(assigns(:user).id).to eq(content_manager_user.id)
      end

      it 'should respond OK to valid params and insist on their own user ID being updated' do
        put :update, id: admin_user.id, user: valid_params
        expect_update_success_with_model('user', account_url)
        expect(assigns(:user).id).to eq(content_manager_user.id)
      end

      it 'should reject invalid params' do
        put :update, id: content_manager_user.id, user: {email: 'a'}
        expect(flash[:success]).to be_nil
        expect(flash[:error]).to be_nil
        expect(response.status).to eq(302)
        expect(response).to redirect_to(account_url(anchor: 'personal-details-modal'))
      end
    end

    describe "DELETE 'destroy'" do
      it 'should redirect to root' do
        delete :destroy, id: 1
        expect_bounce_as_not_allowed
      end
    end

    describe "POST: 'change_password'" do
      it 'should respond OK to correct details' do
        post :change_password, user: {current_password: 'letSomeone1n', password: '456456456', password_confirmation: '456456456'}
        expect_change_password_success_with_model(account_url)
      end

      it 'should respond ERROR to incorrect details' do
        post :change_password, user: {current_password: 'oops', password: '456456456', password_confirmation: '456456456'}
        expect_change_password_error_with_model(account_url)
      end
    end

  end

  context 'Logged in as a marketing_manager_user' do

    before(:each) do
      activate_authlogic
      UserSession.create!(marketing_manager_user)
    end

    describe "GET 'index'" do
      it 'should redirect to root' do
        get :index
        expect_bounce_as_not_allowed
      end
    end

    describe "GET 'show/1'" do
      it 'should see my own profile' do
        get :show, id: marketing_manager_user.id
        expect_bounce_as_not_allowed
      end

      it 'should see my own profile even if I ask for another' do
        get :show, id: marketing_manager_user.id
        expect_bounce_as_not_allowed
      end
    end

    describe "GET account" do
      it 'should see my own profile' do
        get :account, id: marketing_manager_user.id
        expect(flash[:success]).to be_nil
        expect(flash[:error]).to be_nil
        expect(response.status).to eq(200)
        expect(response).to render_template(:account)
      end
    end

    describe "GET 'new'" do
      it 'should redirect to root' do
        get :new
        expect_bounce_as_not_allowed
      end
    end

    describe "GET 'edit/1'" do
      it 'should respond with OK' do
        get :edit, id: marketing_manager_user.id
        expect_bounce_as_not_allowed
      end

      it 'should only allow editing of own user' do
        get :edit, id: marketing_manager_user.id
        expect_bounce_as_not_allowed
      end
    end

    describe "PUT 'update/1'" do
      it 'should respond OK to valid params' do
        put :update, id: marketing_manager_user.id, user: valid_params
        expect_update_success_with_model('user', account_url)
        expect(assigns(:user).id).to eq(marketing_manager_user.id)
      end

      it 'should respond OK to valid params and insist on their own user ID being updated' do
        put :update, id: marketing_manager_user.id, user: valid_params
        expect_update_success_with_model('user', account_url)
        expect(assigns(:user).id).to eq(marketing_manager_user.id)
      end

      it 'should reject invalid params' do
        put :update, id: marketing_manager_user.id, user: {email: 'a'}
        expect(flash[:success]).to be_nil
        expect(flash[:error]).to be_nil
        expect(response.status).to eq(302)
        expect(response).to redirect_to(account_url(anchor: 'personal-details-modal'))
      end
    end

    describe "DELETE 'destroy'" do
      it 'should redirect to root' do
        delete :destroy, id: 1
        expect_bounce_as_not_allowed
      end
    end

    describe "POST: 'change_password'" do
      it 'should respond OK to correct details' do
        post :change_password, user: {current_password: 'letSomeone1n', password: '456456456', password_confirmation: '456456456'}
        expect_change_password_success_with_model(account_url)
      end

      it 'should respond ERROR to incorrect details' do
        post :change_password, user: {current_password: 'oops', password: '456456456', password_confirmation: '456456456'}
        expect_change_password_error_with_model(account_url)
      end
    end

  end

  context 'Logged in as a customer_support_manager_user' do

    before(:each) do
      activate_authlogic
      UserSession.create!(customer_support_manager_user)
    end

    describe "GET 'index'" do
      it 'should redirect to root' do
        get :index
        expect_index_success_with_model('users', User.all.count)
      end
    end

    describe "GET 'show/1'" do
      it 'should see my own profile' do
        get :show, id: individual_student_user.id
        expect_show_success_with_model('user', individual_student_user.id)
      end

      it 'should see my own profile even if I ask for another' do
        get :show, id: customer_support_manager_user.id
        expect_show_success_with_model('user', customer_support_manager_user.id)
      end
    end

    describe "GET account" do
      it 'should see my own profile' do
        get :account, id: customer_support_manager_user.id
        expect(flash[:success]).to be_nil
        expect(flash[:error]).to be_nil
        expect(response.status).to eq(200)
        expect(response).to render_template(:account)
      end

    end

    describe "GET 'new'" do
      it 'should redirect to root' do
        get :new
        expect_new_success_with_model('user')
      end
    end

    describe "GET 'edit/1'" do
      it 'should respond with OK' do
        get :edit, id: customer_support_manager_user.id
        expect_edit_success_with_model('user', customer_support_manager_user.id)
      end

    end

    describe "POST 'admin create'" do
      it 'should report OK for valid params' do
        post :create, user: valid_params
        expect_bounce_as_not_allowed
      end

      it 'should report error for invalid params' do
        post :create, user: {email: 'abc'}
        expect_bounce_as_not_allowed
      end
    end

    describe "PUT 'update/1'" do
      it 'should respond OK to valid params' do
        put :update, id: individual_student_user.id, user: valid_params
        expect_update_success_with_model('user', users_url)
      end

      it 'should respond OK to valid params and insist on their own user ID being updated' do
        put :update, id: individual_student_user.id, user: valid_params
        expect_update_success_with_model('user', users_url)
        expect(assigns(:user).id).to eq(individual_student_user.id)
      end

      it 'should reject invalid params' do
        put :update, id: individual_student_user.id, user: {email: 'a'}
        expect_update_error_with_model('user')
        expect(assigns(:user).id).to eq(individual_student_user.id)
      end
    end

    describe "DELETE 'destroy'" do
      it 'should be OK if deleting normal user' do
        delete :destroy, id: individual_student_user.id
        expect_bounce_as_not_allowed
      end

      it 'should be ERROR if deleting admin user' do
        delete :destroy, id: admin_user.id
        expect_bounce_as_not_allowed
      end
    end

    describe "POST: 'change_password'" do
      it 'should respond OK to correct details' do
        post :change_password, user: {current_password: 'letSomeone1n', password: '456456456', password_confirmation: '456456456'}
        expect_change_password_success_with_model(users_url)
      end

      it 'should respond ERROR to incorrect details' do
        post :change_password, user: {current_password: 'oops', password: '456456456', password_confirmation: '456456456'}
        expect_change_password_error_with_model(users_url)
      end
    end

  end

  context 'Logged in as a admin_user' do

    before(:each) do
      activate_authlogic
      UserSession.create!(admin_user)
    end

    describe "GET 'index'" do
      it 'should redirect to root' do
        get :index
        expect_index_success_with_model('users', User.all.count)
      end
    end

    describe "GET 'show/1'" do
      it 'should see my own profile' do
        get :show, id: individual_student_user.id
        expect_show_success_with_model('user', individual_student_user.id)
      end

      it 'should see my own profile even if I ask for another' do
        get :show, id: admin_user.id
        expect_show_success_with_model('user', admin_user.id)
      end
    end

    describe "GET account" do
      it 'should see my own profile' do
        get :account, id: individual_student_user.id
        expect(flash[:success]).to be_nil
        expect(flash[:error]).to be_nil
        expect(response.status).to eq(200)
        expect(response).to render_template(:account)
      end

    end

    describe "GET 'new'" do
      it 'should redirect to root' do
        get :new
        expect_new_success_with_model('user')
      end
    end

    describe "GET 'edit/1'" do
      it 'should respond with OK' do
        get :edit, id: individual_student_user.id
        expect_edit_success_with_model('user', individual_student_user.id)
      end

      it 'should only allow editing of own user' do
        get :edit, id: admin_user.id
        expect_edit_success_with_model('user', admin_user.id)
      end
    end

    describe "POST 'admin create'" do
      it 'should report OK for valid params' do
        referral_codes = ReferralCode.count
        post :create, user: valid_params
        expect_create_success_with_model('user', users_url)
        expect(assigns(:user).password_change_required).to eq(true)
        expect(ReferralCode.count).to eq(referral_codes + 1)
      end

      it 'should report error for invalid params' do
        post :create, user: {email: 'abc'}
        expect_create_error_with_model('user')
      end
    end

    describe "PUT 'update/1'" do
      it 'should respond OK to valid params' do
        put :update, id: admin_user.id, user: valid_params
        expect_update_success_with_model('user', users_url)
      end

      it 'should respond OK to valid params and insist on their own user ID being updated' do
        put :update, id: individual_student_user.id, user: valid_params
        expect_update_success_with_model('user', users_url)
        expect(assigns(:user).id).to eq(individual_student_user.id)
      end

      it 'should reject invalid params' do
        put :update, id: individual_student_user.id, user: {email: 'a'}
        expect_update_error_with_model('user')
        expect(assigns(:user).id).to eq(individual_student_user.id)
      end
    end

    describe "DELETE 'destroy'" do
      it 'should be OK if deleting normal user' do
        delete :destroy, id: individual_student_user.id
        expect_delete_success_with_model('user', users_url)
      end

      it 'should be ERROR if deleting admin user' do
        delete :destroy, id: admin_user.id
        expect_delete_error_with_model('user', users_url)
      end
    end

    describe "POST: 'change_password'" do
      it 'should respond OK to correct details' do
        post :change_password, user: {current_password: 'letSomeone1n', password: '456456456', password_confirmation: '456456456'}
        expect_change_password_success_with_model(users_url)
      end

      it 'should respond ERROR to incorrect details' do
        post :change_password, user: {current_password: 'oops', password: '456456456', password_confirmation: '456456456'}
        expect_change_password_error_with_model(users_url)
      end
    end

  end

end
