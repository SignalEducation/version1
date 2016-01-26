# == Schema Information
#
# Table name: user_notifications
#
#  id             :integer          not null, primary key
#  user_id        :integer
#  subject_line   :string
#  content        :text
#  email_required :boolean          default(FALSE), not null
#  email_sent_at  :datetime
#  unread         :boolean          default(TRUE), not null
#  destroyed_at   :datetime
#  message_type   :string
#  tutor_id       :integer
#  falling_behind :boolean          not null
#  blog_post_id   :integer
#  created_at     :datetime
#  updated_at     :datetime
#

require 'rails_helper'
require 'support/users_and_groups_setup'

describe UserNotificationsController, type: :controller do

  include_context 'users_and_groups_setup'

  let!(:user_notification_1) { FactoryGirl.create(:user_notification, user_id: individual_student_user.id) }
  let!(:user_notification_2) { FactoryGirl.create(:user_notification, user_id: tutor_user.id) }
  let!(:user_notification_3) { FactoryGirl.create(:user_notification, user_id: corporate_student_user.id) }
  let!(:user_notification_4) { FactoryGirl.create(:user_notification, user_id: corporate_customer_user.id) }
  let!(:user_notification_5) { FactoryGirl.create(:user_notification, user_id: blogger_user.id) }
  let!(:user_notification_6) { FactoryGirl.create(:user_notification, user_id: forum_manager_user.id) }
  let!(:user_notification_7) { FactoryGirl.create(:user_notification, user_id: content_manager_user.id) }
  let!(:user_notification_8) { FactoryGirl.create(:user_notification, user_id: admin_user.id) }
  let!(:valid_params) { FactoryGirl.attributes_for(:user_notification) }

  context 'Not logged in: ' do

    describe "GET 'index'" do
      it 'should redirect to sign_in' do
        get :index
        expect_bounce_as_not_signed_in
      end
    end

    describe "GET 'show/1'" do
      it 'should redirect to sign_in' do
        get :show, id: 1
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
      it 'should respond OK' do
        get :index
        expect_index_success_with_model('user_notifications', 1)
      end
    end

    describe "GET 'show/x'" do
      it 'should see user_notification_1' do
        get :show, id: user_notification_1.id
        expect_show_success_with_model('user_notification', user_notification_1.id)
      end

      # optional - some other object
      it 'should bounce as not allowed' do
        get :show, id: user_notification_2.id
        expect_bounce_as_not_allowed
      end
    end

    describe "GET 'new'" do
      it 'should respond OK' do
        get :new
        expect_bounce_as_not_allowed
      end
    end

    describe "GET 'edit/x'" do
      it 'should respond OK with user_notification_1' do
        get :edit, id: user_notification_1.id
        expect_bounce_as_not_allowed
      end

      # optional
      it 'should bounce as not allowed' do
        get :edit, id: user_notification_2.id
        expect_bounce_as_not_allowed
      end
    end

    describe "POST 'create'" do
      it 'should bounce as not allowed' do
        post :create, user_notification: valid_params
        expect_bounce_as_not_allowed
      end
    end

    describe "PUT 'update/x'" do
      it 'should respond OK to valid params for user_notification_2' do
        put :update, id: user_notification_1.id, user_notification: valid_params
        expect_update_success_with_model('user_notification', user_notifications_url)
      end

      # optional
      it 'should bounce as not allowed' do
        put :update, id: user_notification_2.id, user_notification: valid_params
        expect_bounce_as_not_allowed
      end

      it 'should reject invalid params' do
        put :update, id: user_notification_1.id, user_notification: {valid_params.keys.first => ''}
        expect_update_error_with_model('user_notification')
        expect(assigns(:user_notification).id).to eq(user_notification_1.id)
      end
    end

    describe "DELETE 'destroy'" do
      it 'should get OK' do
        delete :destroy, id: user_notification_1.id
        expect_archive_success_with_model('user_notification', user_notification_1.id, user_notifications_url)
      end

      it 'should get bounced as not allowed' do
        delete :destroy, id: user_notification_2.id
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
      it 'should respond OK' do
        get :index
        expect_index_success_with_model('user_notifications', 1)
      end
    end

    describe "GET 'show/x'" do
      it 'should see user_notification_2' do
        get :show, id: user_notification_2.id
        expect_show_success_with_model('user_notification', user_notification_2.id)
      end

      # optional - some other object
      it 'should bounce as not allowed' do
        get :show, id: user_notification_1.id
        expect_bounce_as_not_allowed
      end
    end

    describe "GET 'new'" do
      it 'should respond OK' do
        get :new
        expect_new_success_with_model('user_notification')
      end
    end

    describe "GET 'edit/x'" do
      it 'should respond OK with user_notification_2' do
        get :edit, id: user_notification_2.id
        expect_edit_success_with_model('user_notification', user_notification_2.id)
      end

      # optional
      it 'should expect bounce as not allowed' do
        get :edit, id: user_notification_1.id
        expect_bounce_as_not_allowed
      end
    end

    describe "POST 'create'" do
      it 'should report OK for valid params' do
        post :create, user_notification: valid_params
        expect_create_success_with_model('user_notification', user_notifications_url)
      end

      it 'should report error for invalid params' do
        post :create, user_notification: {valid_params.keys.first => ''}
        expect_create_error_with_model('user_notification')
      end
    end

    describe "PUT 'update/x'" do
      it 'should respond OK to valid params for user_notification_2' do
        put :update, id: user_notification_2.id, user_notification: valid_params
        expect_update_success_with_model('user_notification', user_notifications_url)
      end

      # optional
      it 'should bounce as not allowed' do
        put :update, id: user_notification_1.id, user_notification: valid_params
        expect_bounce_as_not_allowed
      end

      it 'should reject invalid params' do
        put :update, id: user_notification_2.id, user_notification: {valid_params.keys.first => ''}
        expect_update_error_with_model('user_notification')
        expect(assigns(:user_notification).id).to eq(user_notification_2.id)
      end
    end


    describe "DELETE 'destroy'" do
      it 'should be OK as no dependencies exist' do
        delete :destroy, id: user_notification_2.id
        expect_archive_success_with_model('user_notification', user_notification_2.id, user_notifications_url)
      end

      it 'should expect bounce as not allowed' do
        delete :destroy, id: user_notification_1.id
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
      it 'should respond OK' do
        get :index
        expect_index_success_with_model('user_notifications', 1)
      end
    end

    describe "GET 'show/x'" do
      it 'should see user_notification_3' do
        get :show, id: user_notification_3.id
        expect_show_success_with_model('user_notification', user_notification_3.id)
      end

      # optional - some other object
      it 'should expect bounce as not allowed' do
        get :show, id: user_notification_2.id
        expect_bounce_as_not_allowed
      end
    end

    describe "GET 'new'" do
      it 'should expect bounce as not allowed' do
        get :new
        expect_bounce_as_not_allowed
      end
    end

    describe "GET 'edit/x'" do
      it 'should expect bounce as not allowed' do
        get :edit, id: user_notification_3.id
        expect_bounce_as_not_allowed
      end
    end

    describe "POST 'create'" do
      it 'should expect bounce as not allowed' do
        post :create, user_notification: valid_params
        expect_bounce_as_not_allowed
      end
    end

    describe "PUT 'update/x'" do
      it 'should respond OK to valid params for user_notification_3' do
        put :update, id: user_notification_3.id, user_notification: valid_params
        expect_update_success_with_model('user_notification', user_notifications_url)
      end

      # optional
      it 'should expect bounce as not allowed' do
        put :update, id: user_notification_1.id, user_notification: valid_params
        expect_bounce_as_not_allowed
      end

      it 'should reject invalid params' do
        put :update, id: user_notification_3.id, user_notification: {valid_params.keys.first => ''}
        expect_update_error_with_model('user_notification')
        expect(assigns(:user_notification).id).to eq(user_notification_3.id)
      end
    end

    describe "DELETE 'destroy'" do
      it 'should be OK as no dependencies exist' do
        delete :destroy, id: user_notification_3.id
        expect_archive_success_with_model('user_notification', user_notification_3.id, user_notifications_url)
      end

      it 'should bounce as not allowed' do
        delete :destroy, id: user_notification_2.id
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
      it 'should respond OK' do
        get :index
        expect_index_success_with_model('user_notifications', 1)
      end
    end

    describe "GET 'show/x'" do
      it 'should see user_notification_4' do
        get :show, id: user_notification_4.id
        expect_show_success_with_model('user_notification', user_notification_4.id)
      end

      it 'should bounce as not allowed' do
        get :show, id: user_notification_2.id
        expect_bounce_as_not_allowed
      end
    end

    describe "GET 'new'" do
      it 'should bounce as not allowed' do
        get :new
        expect_bounce_as_not_allowed
      end
    end

    describe "GET 'edit/x'" do
      it 'should respond OK with user_notification_4' do
        get :edit, id: user_notification_4.id
        expect_bounce_as_not_allowed
      end
    end

    describe "POST 'create'" do
      it 'should report OK for valid params' do
        post :create, user_notification: valid_params
        expect_bounce_as_not_allowed
      end
    end

    describe "PUT 'update/x'" do
      it 'should respond OK to valid params for user_notification_4' do
        put :update, id: user_notification_4.id, user_notification: valid_params
        expect_update_success_with_model('user_notification', user_notifications_url)
      end

      it 'should bounce as not allowed' do
        put :update, id: user_notification_2.id, user_notification: valid_params
        expect_bounce_as_not_allowed
      end

      it 'should reject invalid params' do
        put :update, id: user_notification_4.id, user_notification: {valid_params.keys.first => ''}
        expect_update_error_with_model('user_notification')
        expect(assigns(:user_notification).id).to eq(user_notification_4.id)
      end
    end

    describe "DELETE 'destroy'" do
      it 'should be OK as no dependencies exist' do
        delete :destroy, id: user_notification_4.id
        expect_archive_success_with_model('user_notification', user_notification_4.id, user_notifications_url)
      end

      it 'should bounce as not allowed' do
        delete :destroy, id: user_notification_7.id
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
      it 'should respond OK' do
        get :index
        expect_index_success_with_model('user_notifications', 1)
      end
    end

    describe "GET 'show/x'" do
      it 'should see user_notification_5' do
        get :show, id: user_notification_5.id
        expect_show_success_with_model('user_notification', user_notification_5.id)
      end

      it 'should bounce as not allowed' do
        get :show, id: user_notification_2.id
        expect_bounce_as_not_allowed
      end
    end

    describe "GET 'new'" do
      it 'should bounce as not allowed' do
        get :new
        expect_bounce_as_not_allowed
      end
    end

    describe "GET 'edit/x'" do
      it 'should bounce as not alloowed' do
        get :edit, id: user_notification_5.id
        expect_bounce_as_not_allowed
      end
    end

    describe "POST 'create'" do
      it 'should bounce as not allowed' do
        post :create, user_notification: valid_params
        expect_bounce_as_not_allowed
      end
    end

    describe "PUT 'update/x'" do
      it 'should respond OK to valid params for user_notification_1' do
        put :update, id: user_notification_5.id, user_notification: valid_params
        expect_update_success_with_model('user_notification', user_notifications_url)
      end

      it 'should bounce as not allowed' do
        put :update, id: user_notification_2.id, user_notification: valid_params
        expect_bounce_as_not_allowed
      end

      it 'should reject invalid params' do
        put :update, id: user_notification_5.id, user_notification: {valid_params.keys.first => ''}
        expect_update_error_with_model('user_notification')
        expect(assigns(:user_notification).id).to eq(user_notification_5.id)
      end
    end

    describe "DELETE 'destroy'" do
      it 'should be OK as no dependencies exist' do
        delete :destroy, id: user_notification_5.id
        expect_archive_success_with_model('user_notification', user_notification_5.id, user_notifications_url)
      end

      it 'should bounce as not allowed' do
        delete :destroy, id: user_notification_2.id
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
      it 'should respond OK' do
        get :index
        expect_index_success_with_model('user_notifications', 1)
      end
    end

    describe "GET 'show/x'" do
      it 'should see user_notification_6' do
        get :show, id: user_notification_6.id
        expect_show_success_with_model('user_notification', user_notification_6.id)
      end

      it 'should bounce as not allowed' do
        get :show, id: user_notification_2.id
        expect_bounce_as_not_allowed
      end
    end

    describe "GET 'new'" do
      it 'should bounce as not allowed' do
        get :new
        expect_bounce_as_not_allowed
      end
    end

    describe "GET 'edit/x'" do
      it 'should bounce as not allowed' do
        get :edit, id: user_notification_6.id
        expect_bounce_as_not_allowed
      end
    end

    describe "POST 'create'" do
      it 'should bounce as not allowed' do
        post :create, user_notification: valid_params
        expect_bounce_as_not_allowed
      end
    end

    describe "PUT 'update/x'" do
      it 'should respond OK to valid params for user_notification_6' do
        put :update, id: user_notification_6.id, user_notification: valid_params
        expect_update_success_with_model('user_notification', user_notifications_url)
      end

      it 'should bounce as not allowed' do
        put :update, id: user_notification_2.id, user_notification: valid_params
        expect_bounce_as_not_allowed
      end

      it 'should reject invalid params' do
        put :update, id: user_notification_6.id, user_notification: {valid_params.keys.first => ''}
        expect_update_error_with_model('user_notification')
        expect(assigns(:user_notification).id).to eq(user_notification_6.id)
      end
    end

    describe "DELETE 'destroy'" do
      it 'should be OK as no dependencies exist' do
        delete :destroy, id: user_notification_6.id
        expect_archive_success_with_model('user_notification', user_notification_6.id, user_notifications_url)
      end
    end

  end

  context 'Logged in as a content_manager_user: ' do

    before(:each) do
      activate_authlogic
      UserSession.create!(content_manager_user)
    end

    describe "GET 'index'" do
      it 'should respond OK' do
        get :index
        expect_index_success_with_model('user_notifications', 1)
      end
    end

    describe "GET 'show/x'" do
      it 'should see user_notification_7' do
        get :show, id: user_notification_7.id
        expect_show_success_with_model('user_notification', user_notification_7.id)
      end

      it 'should bounce as not allowed' do
        get :show, id: user_notification_2.id
        expect_bounce_as_not_allowed
      end
    end

    describe "GET 'new'" do
      it 'should bounce as not allowed' do
        get :new
        expect_bounce_as_not_allowed
      end
    end

    describe "GET 'edit/1'" do
      it 'should bounce as not allowed' do
        get :edit, id: user_notification_7.id
        expect_bounce_as_not_allowed
      end
    end

    describe "POST 'create'" do
      it 'should bounce as not allowed' do
        post :create, user_notification: valid_params
        expect_bounce_as_not_allowed
      end
    end

    describe "PUT 'update/x'" do
      it 'should respond OK to valid params for user_notification_7' do
        put :update, id: user_notification_7.id, user_notification: valid_params
        expect_update_success_with_model('user_notification', user_notifications_url)
      end

      it 'should bounce as not allowed' do
        put :update, id: user_notification_2.id, user_notification: valid_params
        expect_bounce_as_not_allowed
      end

      it 'should reject invalid params' do
        put :update, id: user_notification_7.id, user_notification: {valid_params.keys.first => ''}
        expect_update_error_with_model('user_notification')
        expect(assigns(:user_notification).id).to eq(user_notification_7.id)
      end
    end

    describe "DELETE 'destroy'" do
      it 'should be OK as no dependencies exist' do
        delete :destroy, id: user_notification_7.id
        expect_archive_success_with_model('user_notification', user_notification_7.id, user_notifications_url)
      end
    end

  end

  context 'Logged in as a admin_user: ' do

    before(:each) do
      activate_authlogic
      UserSession.create!(admin_user)
    end

    describe "GET 'index'" do
      it 'should respond OK' do
        get :index
        expect_index_success_with_model('user_notifications', 8)
      end
    end

    describe "GET 'show/x'" do
      it 'should see user_notification_8' do
        get :show, id: user_notification_8.id
        expect_show_success_with_model('user_notification', user_notification_8.id)
      end

      it 'should see user_notification_2' do
        get :show, id: user_notification_2.id
        expect_show_success_with_model('user_notification', user_notification_2.id)
      end
    end

    describe "GET 'new'" do
      it 'should respond OK' do
        get :new
        expect_new_success_with_model('user_notification')
      end
    end

    describe "GET 'edit/x'" do
      it 'should respond OK with user_notification_8' do
        get :edit, id: user_notification_8.id
        expect_edit_success_with_model('user_notification', user_notification_8.id)
      end

      it 'should respond OK with user_notification_2' do
        get :edit, id: user_notification_2.id
        expect_edit_success_with_model('user_notification', user_notification_2.id)
      end
    end

    describe "POST 'create'" do
      it 'should report OK for valid params' do
        post :create, user_notification: valid_params
        expect_create_success_with_model('user_notification', user_notifications_url)
      end

      it 'should report error for invalid params' do
        post :create, user_notification: {valid_params.keys.first => ''}
        expect_create_error_with_model('user_notification')
      end
    end

    describe "PUT 'update/x'" do
      it 'should respond OK to valid params for user_notification_8' do
        put :update, id: user_notification_8.id, user_notification: valid_params
        expect_update_success_with_model('user_notification', user_notifications_url)
      end

      it 'should respond OK to valid params for user_notification_2' do
        put :update, id: user_notification_2.id, user_notification: valid_params
        expect_update_success_with_model('user_notification', user_notifications_url)
        expect(assigns(:user_notification).id).to eq(user_notification_2.id)
      end

      it 'should reject invalid params' do
        put :update, id: user_notification_8.id, user_notification: {valid_params.keys.first => ''}
        expect_update_error_with_model('user_notification')
        expect(assigns(:user_notification).id).to eq(user_notification_8.id)
      end
    end


    describe "DELETE 'destroy'" do
      it 'should be OK as no dependencies exist' do
        delete :destroy, id: user_notification_8.id
        expect_archive_success_with_model('user_notification', user_notification_8.id, user_notifications_url)
      end

      it 'should be OK as no dependencies exist' do
        delete :destroy, id: user_notification_1.id
        expect_archive_success_with_model('user_notification', user_notification_1.id, user_notifications_url)
      end
    end

  end

end
