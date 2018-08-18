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
#  student_number                   :string
#  unsubscribed_from_emails         :boolean          default(FALSE)
#  communication_approval           :boolean          default(FALSE)
#  communication_approval_datetime  :datetime
#  tutor_title                      :string
#

require 'rails_helper'
require 'support/system_setup'
require 'support/users_and_groups_setup'

describe UsersController, type: :controller do

  include_context 'system_setup'
  include_context 'users_and_groups_setup'

  trial_limits_seconds = ENV['FREE_TRIAL_LIMIT_IN_SECONDS'].to_i
  trial_limits_days = ENV['FREE_TRIAL_DAYS'].to_i

  let!(:valid_params) { FactoryBot.attributes_for(:student_user, user_group_id: student_user_group.id,
                                                  student_access_attributes: {trial_seconds_limit: trial_limits_seconds,
                                                                              trial_days_limit: trial_limits_days,
                                                                              account_type: 'Trial'}
  ) }
  let!(:update_params) { FactoryBot.attributes_for(:student_user, user_group_id: student_user_group.id) }


  context 'Not logged in...' do

    describe "GET 'index'" do
      it 'should redirect to root' do
        get :index
        expect_bounce_as_not_signed_in
      end
    end

    describe "GET 'show/1'" do
      it 'should redirect to root' do
        get :show, id: student_user.id
        expect_bounce_as_not_signed_in
      end
    end

    describe "GET 'edit/1'" do
      it 'should redirect to root' do
        get :edit, id: student_user.id
        expect_bounce_as_not_signed_in
      end
    end

    describe "GET 'new'" do
      it 'should redirect to root' do
        get :new
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
      it 'should respond OK to valid params' do
        put :update, id: student_user.id, user: valid_params
        expect_bounce_as_not_signed_in
      end

      it 'should reject invalid params' do
        put :update, id: student_user.id, user: {email: 'a'}
        expect_bounce_as_not_signed_in
      end
    end

    describe "DELETE 'destroy'" do
      it 'should redirect to root' do
        delete :destroy, id: 1
        expect_bounce_as_not_signed_in
      end
    end

    describe "GET 'preview_csv_upload'" do
      it 'should redirect to root' do
        post :preview_csv_upload, id: 1
        expect_bounce_as_not_signed_in
      end
    end

    describe "GET 'import_csv_upload'" do
      it 'should redirect to root' do
        post :import_csv_upload, id: 1
        expect_bounce_as_not_signed_in
      end
    end

    describe "GET 'user_personal_details'" do
      it 'should redirect to root' do
        get :user_personal_details, user_id: student_user.id
        expect_bounce_as_not_signed_in
      end
    end

    describe "GET 'user_subscription_status'" do
      it 'should redirect to root' do
        get :user_subscription_status, user_id: student_user.id
        expect_bounce_as_not_signed_in
      end
    end

    describe "GET 'user_enrollments_details'" do
      it 'should redirect to root' do
        get :user_enrollments_details, user_id: student_user.id
        expect_bounce_as_not_signed_in
      end
    end

    describe "GET 'user_purchases_details'" do
      it 'should redirect to root' do
        get :user_purchases_details, user_id: student_user.id
        expect_bounce_as_not_signed_in
      end
    end

    describe "GET 'user_courses_status'" do
      it 'should redirect to root' do
        get :user_courses_status, user_id: tutor_user.id
        expect_bounce_as_not_signed_in
      end
    end

    describe "POST 'update_courses'" do
      it 'should redirect to root' do
        patch :update_courses, user_id: tutor_user.id
        expect_bounce_as_not_signed_in
      end
    end

  end

  context 'Logged in as a valid_trial student_user' do

    before(:each) do
      activate_authlogic
      UserSession.create!(valid_trial_student)
    end

    describe "GET 'index'" do
      it 'should redirect to root' do
        get :index
        expect_bounce_as_not_allowed
      end
    end

    describe "GET 'show/1'" do
      it 'should redirect to root' do
        get :show, id: student_user.id
        expect_bounce_as_not_allowed
      end
    end

    describe "GET 'edit/1'" do
      it 'should redirect to root' do
        get :edit, id: student_user.id
        expect_bounce_as_not_allowed
      end
    end

    describe "GET 'new'" do
      it 'should redirect to root' do
        get :new
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
        put :update, id: student_user.id, user: valid_params
        expect_bounce_as_not_allowed
      end

      it 'should reject invalid params' do
        put :update, id: student_user.id, user: {email: 'a'}
        expect_bounce_as_not_allowed
      end
    end

    describe "DELETE 'destroy'" do
      it 'should redirect to root' do
        delete :destroy, id: 1
        expect_bounce_as_not_allowed
      end
    end

    describe "GET 'preview_csv_upload'" do
      it 'should redirect to root' do
        post :preview_csv_upload, id: 1
        expect_bounce_as_not_allowed
      end
    end

    describe "GET 'import_csv_upload'" do
      it 'should redirect to root' do
        post :import_csv_upload, id: 1
        expect_bounce_as_not_allowed
      end
    end

    describe "GET 'user_personal_details'" do
      it 'should redirect to root' do
        get :user_personal_details, user_id: student_user.id
        expect_bounce_as_not_allowed
      end
    end

    describe "GET 'user_subscription_status'" do
      it 'should redirect to root' do
        get :user_subscription_status, user_id: student_user.id
        expect_bounce_as_not_allowed
      end
    end

    describe "GET 'user_enrollments_details'" do
      it 'should redirect to root' do
        get :user_enrollments_details, user_id: student_user.id
        expect_bounce_as_not_allowed
      end
    end

    describe "GET 'user_purchases_details'" do
      it 'should redirect to root' do
        get :user_purchases_details, user_id: student_user.id
        expect_bounce_as_not_allowed
      end
    end

    describe "GET 'user_courses_status'" do
      it 'should redirect to root' do
        get :user_courses_status, user_id: tutor_user.id
        expect_bounce_as_not_allowed
      end
    end

    describe "POST 'update_courses'" do
      it 'should redirect to root' do
        patch :update_courses, user_id: tutor_user.id
        expect_bounce_as_not_allowed
      end
    end

  end

  context 'Logged in as a invalid_trial student_user' do

    before(:each) do
      activate_authlogic
      UserSession.create!(invalid_trial_student)
    end

    describe "GET 'index'" do
      it 'should redirect to root' do
        get :index
        expect_bounce_as_not_allowed
      end
    end

    describe "GET 'show/1'" do
      it 'should redirect to root' do
        get :show, id: student_user.id
        expect_bounce_as_not_allowed
      end
    end

    describe "GET 'edit/1'" do
      it 'should redirect to root' do
        get :edit, id: student_user.id
        expect_bounce_as_not_allowed
      end
    end

    describe "GET 'new'" do
      it 'should redirect to root' do
        get :new
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
        put :update, id: student_user.id, user: valid_params
        expect_bounce_as_not_allowed
      end

      it 'should reject invalid params' do
        put :update, id: student_user.id, user: {email: 'a'}
        expect_bounce_as_not_allowed
      end
    end

    describe "DELETE 'destroy'" do
      it 'should redirect to root' do
        delete :destroy, id: 1
        expect_bounce_as_not_allowed
      end
    end

    describe "GET 'preview_csv_upload'" do
      it 'should redirect to root' do
        post :preview_csv_upload, id: 1
        expect_bounce_as_not_allowed
      end
    end

    describe "GET 'import_csv_upload'" do
      it 'should redirect to root' do
        post :import_csv_upload, id: 1
        expect_bounce_as_not_allowed
      end
    end

    describe "GET 'user_personal_details'" do
      it 'should redirect to root' do
        get :user_personal_details, user_id: student_user.id
        expect_bounce_as_not_allowed
      end
    end

    describe "GET 'user_subscription_status'" do
      it 'should redirect to root' do
        get :user_subscription_status, user_id: student_user.id
        expect_bounce_as_not_allowed
      end
    end

    describe "GET 'user_enrollments_details'" do
      it 'should redirect to root' do
        get :user_enrollments_details, user_id: student_user.id
        expect_bounce_as_not_allowed
      end
    end

    describe "GET 'user_purchases_details'" do
      it 'should redirect to root' do
        get :user_purchases_details, user_id: student_user.id
        expect_bounce_as_not_allowed
      end
    end

    describe "GET 'user_courses_status'" do
      it 'should redirect to root' do
        get :user_courses_status, user_id: tutor_user.id
        expect_bounce_as_not_allowed
      end
    end

    describe "POST 'update_courses'" do
      it 'should redirect to root' do
        patch :update_courses, user_id: tutor_user.id
        expect_bounce_as_not_allowed
      end
    end

  end

  context 'Logged in as a valid_subscription student_user' do

    before(:each) do
      activate_authlogic
      UserSession.create!(valid_subscription_student)
    end

    describe "GET 'index'" do
      it 'should redirect to root' do
        get :index
        expect_bounce_as_not_allowed
      end
    end

    describe "GET 'show/1'" do
      it 'should redirect to root' do
        get :show, id: student_user.id
        expect_bounce_as_not_allowed
      end
    end

    describe "GET 'edit/1'" do
      it 'should redirect to root' do
        get :edit, id: student_user.id
        expect_bounce_as_not_allowed
      end
    end

    describe "GET 'new'" do
      it 'should redirect to root' do
        get :new
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
        put :update, id: student_user.id, user: valid_params
        expect_bounce_as_not_allowed
      end

      it 'should reject invalid params' do
        put :update, id: student_user.id, user: {email: 'a'}
        expect_bounce_as_not_allowed
      end
    end

    describe "DELETE 'destroy'" do
      it 'should redirect to root' do
        delete :destroy, id: 1
        expect_bounce_as_not_allowed
      end
    end

    describe "GET 'preview_csv_upload'" do
      it 'should redirect to root' do
        post :preview_csv_upload, id: 1
        expect_bounce_as_not_allowed
      end
    end

    describe "GET 'import_csv_upload'" do
      it 'should redirect to root' do
        post :import_csv_upload, id: 1
        expect_bounce_as_not_allowed
      end
    end

    describe "GET 'user_personal_details'" do
      it 'should redirect to root' do
        get :user_personal_details, user_id: student_user.id
        expect_bounce_as_not_allowed
      end
    end

    describe "GET 'user_subscription_status'" do
      it 'should redirect to root' do
        get :user_subscription_status, user_id: student_user.id
        expect_bounce_as_not_allowed
      end
    end

    describe "GET 'user_enrollments_details'" do
      it 'should redirect to root' do
        get :user_enrollments_details, user_id: student_user.id
        expect_bounce_as_not_allowed
      end
    end

    describe "GET 'user_purchases_details'" do
      it 'should redirect to root' do
        get :user_purchases_details, user_id: student_user.id
        expect_bounce_as_not_allowed
      end
    end

    describe "GET 'user_courses_status'" do
      it 'should redirect to root' do
        get :user_courses_status, user_id: tutor_user.id
        expect_bounce_as_not_allowed
      end
    end

    describe "POST 'update_courses'" do
      it 'should redirect to root' do
        patch :update_courses, user_id: tutor_user.id
        expect_bounce_as_not_allowed
      end
    end

  end

  context 'Logged in as a invalid_subscription student_user' do

    before(:each) do
      activate_authlogic
      UserSession.create!(invalid_subscription_student)
    end

    describe "GET 'index'" do
      it 'should redirect to root' do
        get :index
        expect_bounce_as_not_allowed
      end
    end

    describe "GET 'show/1'" do
      it 'should redirect to root' do
        get :show, id: student_user.id
        expect_bounce_as_not_allowed
      end
    end

    describe "GET 'edit/1'" do
      it 'should redirect to root' do
        get :edit, id: student_user.id
        expect_bounce_as_not_allowed
      end
    end

    describe "GET 'new'" do
      it 'should redirect to root' do
        get :new
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
        put :update, id: student_user.id, user: valid_params
        expect_bounce_as_not_allowed
      end

      it 'should reject invalid params' do
        put :update, id: student_user.id, user: {email: 'a'}
        expect_bounce_as_not_allowed
      end
    end

    describe "DELETE 'destroy'" do
      it 'should redirect to root' do
        delete :destroy, id: 1
        expect_bounce_as_not_allowed
      end
    end

    describe "GET 'preview_csv_upload'" do
      it 'should redirect to root' do
        post :preview_csv_upload, id: 1
        expect_bounce_as_not_allowed
      end
    end

    describe "GET 'import_csv_upload'" do
      it 'should redirect to root' do
        post :import_csv_upload, id: 1
        expect_bounce_as_not_allowed
      end
    end

    describe "GET 'user_personal_details'" do
      it 'should redirect to root' do
        get :user_personal_details, user_id: student_user.id
        expect_bounce_as_not_allowed
      end
    end

    describe "GET 'user_subscription_status'" do
      it 'should redirect to root' do
        get :user_subscription_status, user_id: student_user.id
        expect_bounce_as_not_allowed
      end
    end

    describe "GET 'user_enrollments_details'" do
      it 'should redirect to root' do
        get :user_enrollments_details, user_id: student_user.id
        expect_bounce_as_not_allowed
      end
    end

    describe "GET 'user_purchases_details'" do
      it 'should redirect to root' do
        get :user_purchases_details, user_id: student_user.id
        expect_bounce_as_not_allowed
      end
    end

    describe "GET 'user_courses_status'" do
      it 'should redirect to root' do
        get :user_courses_status, user_id: tutor_user.id
        expect_bounce_as_not_allowed
      end
    end

    describe "POST 'update_courses'" do
      it 'should redirect to root' do
        patch :update_courses, user_id: tutor_user.id
        expect_bounce_as_not_allowed
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

    describe "GET 'show/1'" do
      it 'should redirect to root' do
        get :show, id: student_user.id
        expect_bounce_as_not_allowed
      end
    end

    describe "GET 'edit/1'" do
      it 'should redirect to root' do
        get :edit, id: student_user.id
        expect_bounce_as_not_allowed
      end
    end

    describe "GET 'new'" do
      it 'should redirect to root' do
        get :new
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
        put :update, id: student_user.id, user: valid_params
        expect_bounce_as_not_allowed
      end

      it 'should reject invalid params' do
        put :update, id: student_user.id, user: {email: 'a'}
        expect_bounce_as_not_allowed
      end
    end

    describe "DELETE 'destroy'" do
      it 'should redirect to root' do
        delete :destroy, id: 1
        expect_bounce_as_not_allowed
      end
    end

    describe "GET 'preview_csv_upload'" do
      it 'should redirect to root' do
        post :preview_csv_upload, id: 1
        expect_bounce_as_not_allowed
      end
    end

    describe "GET 'import_csv_upload'" do
      it 'should redirect to root' do
        post :import_csv_upload, id: 1
        expect_bounce_as_not_allowed
      end
    end

    describe "GET 'user_personal_details'" do
      it 'should redirect to root' do
        get :user_personal_details, user_id: student_user.id
        expect_bounce_as_not_allowed
      end
    end

    describe "GET 'user_subscription_status'" do
      it 'should redirect to root' do
        get :user_subscription_status, user_id: student_user.id
        expect_bounce_as_not_allowed
      end
    end

    describe "GET 'user_enrollments_details'" do
      it 'should redirect to root' do
        get :user_enrollments_details, user_id: student_user.id
        expect_bounce_as_not_allowed
      end
    end

    describe "GET 'user_purchases_details'" do
      it 'should redirect to root' do
        get :user_purchases_details, user_id: student_user.id
        expect_bounce_as_not_allowed
      end
    end

    describe "GET 'user_courses_status'" do
      it 'should redirect to root' do
        get :user_courses_status, user_id: tutor_user.id
        expect_bounce_as_not_allowed
      end
    end

    describe "POST 'update_courses'" do
      it 'should redirect to root' do
        patch :update_courses, user_id: tutor_user.id
        expect_bounce_as_not_allowed
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
      it 'should redirect to root' do
        get :show, id: student_user.id
        expect_bounce_as_not_allowed
      end
    end

    describe "GET 'edit/1'" do
      it 'should redirect to root' do
        get :edit, id: student_user.id
        expect_bounce_as_not_allowed
      end
    end

    describe "GET 'new'" do
      it 'should redirect to root' do
        get :new
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
        put :update, id: student_user.id, user: valid_params
        expect_bounce_as_not_allowed
      end

      it 'should reject invalid params' do
        put :update, id: student_user.id, user: {email: 'a'}
        expect_bounce_as_not_allowed
      end
    end

    describe "DELETE 'destroy'" do
      it 'should redirect to root' do
        delete :destroy, id: 1
        expect_bounce_as_not_allowed
      end
    end

    describe "GET 'preview_csv_upload'" do
      it 'should redirect to root' do
        post :preview_csv_upload, id: 1
        expect_bounce_as_not_allowed
      end
    end

    describe "GET 'import_csv_upload'" do
      it 'should redirect to root' do
        post :import_csv_upload, id: 1
        expect_bounce_as_not_allowed
      end
    end

    describe "GET 'user_personal_details'" do
      it 'should redirect to root' do
        get :user_personal_details, user_id: student_user.id
        expect_bounce_as_not_allowed
      end
    end

    describe "GET 'user_subscription_status'" do
      it 'should redirect to root' do
        get :user_subscription_status, user_id: student_user.id
        expect_bounce_as_not_allowed
      end
    end

    describe "GET 'user_enrollments_details'" do
      it 'should redirect to root' do
        get :user_enrollments_details, user_id: student_user.id
        expect_bounce_as_not_allowed
      end
    end

    describe "GET 'user_purchases_details'" do
      it 'should redirect to root' do
        get :user_purchases_details, user_id: student_user.id
        expect_bounce_as_not_allowed
      end
    end

    describe "GET 'user_courses_status'" do
      it 'should redirect to root' do
        get :user_courses_status, user_id: tutor_user.id
        expect_bounce_as_not_allowed
      end
    end

    describe "POST 'update_courses'" do
      it 'should redirect to root' do
        patch :update_courses, user_id: tutor_user.id
        expect_bounce_as_not_allowed
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
      it 'should redirect to root' do
        get :show, id: student_user.id
        expect_bounce_as_not_allowed
      end
    end

    describe "GET 'edit/1'" do
      it 'should redirect to root' do
        get :edit, id: student_user.id
        expect_bounce_as_not_allowed
      end
    end

    describe "GET 'new'" do
      it 'should redirect to root' do
        get :new
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
        put :update, id: student_user.id, user: valid_params
        expect_bounce_as_not_allowed
      end

      it 'should reject invalid params' do
        put :update, id: student_user.id, user: {email: 'a'}
        expect_bounce_as_not_allowed
      end
    end

    describe "DELETE 'destroy'" do
      it 'should redirect to root' do
        delete :destroy, id: 1
        expect_bounce_as_not_allowed
      end
    end

    describe "GET 'preview_csv_upload'" do
      it 'should redirect to root' do
        post :preview_csv_upload, id: 1
        expect_bounce_as_not_allowed
      end
    end

    describe "GET 'import_csv_upload'" do
      it 'should redirect to root' do
        post :import_csv_upload, id: 1
        expect_bounce_as_not_allowed
      end
    end

    describe "GET 'user_personal_details'" do
      it 'should redirect to root' do
        get :user_personal_details, user_id: student_user.id
        expect_bounce_as_not_allowed
      end
    end

    describe "GET 'user_subscription_status'" do
      it 'should redirect to root' do
        get :user_subscription_status, user_id: student_user.id
        expect_bounce_as_not_allowed
      end
    end

    describe "GET 'user_enrollments_details'" do
      it 'should redirect to root' do
        get :user_enrollments_details, user_id: student_user.id
        expect_bounce_as_not_allowed
      end
    end

    describe "GET 'user_purchases_details'" do
      it 'should redirect to root' do
        get :user_purchases_details, user_id: student_user.id
        expect_bounce_as_not_allowed
      end
    end

    describe "GET 'user_courses_status'" do
      it 'should redirect to root' do
        get :user_courses_status, user_id: tutor_user.id
        expect_bounce_as_not_allowed
      end
    end

    describe "POST 'update_courses'" do
      it 'should redirect to root' do
        patch :update_courses, user_id: tutor_user.id
        expect_bounce_as_not_allowed
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
      it 'should redirect to root' do
        get :show, id: student_user.id
        expect_bounce_as_not_allowed
      end
    end

    describe "GET 'edit/1'" do
      it 'should redirect to root' do
        get :edit, id: student_user.id
        expect_bounce_as_not_allowed
      end
    end

    describe "GET 'new'" do
      it 'should redirect to root' do
        get :new
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
        put :update, id: student_user.id, user: valid_params
        expect_bounce_as_not_allowed
      end

      it 'should reject invalid params' do
        put :update, id: student_user.id, user: {email: 'a'}
        expect_bounce_as_not_allowed
      end
    end

    describe "DELETE 'destroy'" do
      it 'should redirect to root' do
        delete :destroy, id: 1
        expect_bounce_as_not_allowed
      end
    end

    describe "GET 'preview_csv_upload'" do
      it 'should redirect to root' do
        post :preview_csv_upload, id: 1
        expect_bounce_as_not_allowed
      end
    end

    describe "GET 'import_csv_upload'" do
      it 'should redirect to root' do
        post :import_csv_upload, id: 1
        expect_bounce_as_not_allowed
      end
    end

    describe "GET 'user_personal_details'" do
      it 'should redirect to root' do
        get :user_personal_details, user_id: student_user.id
        expect_bounce_as_not_allowed
      end
    end

    describe "GET 'user_subscription_status'" do
      it 'should redirect to root' do
        get :user_subscription_status, user_id: student_user.id
        expect_bounce_as_not_allowed
      end
    end

    describe "GET 'user_enrollments_details'" do
      it 'should redirect to root' do
        get :user_enrollments_details, user_id: student_user.id
        expect_bounce_as_not_allowed
      end
    end

    describe "GET 'user_purchases_details'" do
      it 'should redirect to root' do
        get :user_purchases_details, user_id: student_user.id
        expect_bounce_as_not_allowed
      end
    end

    describe "GET 'user_courses_status'" do
      it 'should redirect to root' do
        get :user_courses_status, user_id: tutor_user.id
        expect_bounce_as_not_allowed
      end
    end

    describe "POST 'update_courses'" do
      it 'should redirect to root' do
        patch :update_courses, user_id: tutor_user.id
        expect_bounce_as_not_allowed
      end
    end

  end

  context 'Logged in as a customer_support_manager_user' do

    before(:each) do
      activate_authlogic
      UserSession.create!(customer_support_manager_user)
    end

    describe "GET 'index'" do
      it 'should successfully render index' do
        get :index
        expect_index_success_with_model('users', User.all.count)
      end
    end

    describe "GET 'show'" do
      it 'should successfully render show' do
        get :show, id: student_user.id
        expect_show_success_with_model('user', student_user.id)
      end
    end

    describe "GET 'edit/1'" do
      it 'should successfully render edit' do
        get :edit, id: student_user.id
        expect_edit_success_with_model('user', student_user.id)
      end
    end

    describe "GET 'new'" do
      it 'should successfully render new' do
        get :new
        expect_new_success_with_model('user')
      end
    end

    describe "POST 'create'" do
      it 'should successfully create record' do
        post :create, user: valid_params
        expect_create_success_with_model('user', users_url)
        expect(assigns(:user).password_change_required).to eq(true)
      end
    end

    describe "PUT 'update'" do
      it 'should respond OK to valid params' do
        put :update, id: student_user.id, user: update_params
        expect_update_success_with_model('user', users_url)
      end

      it 'should reject invalid params' do
        put :update, id: student_user.id, user: {email: 'a'}
        expect(flash[:success]).to be_nil
        expect(flash[:error]).to eq(I18n.t('controllers.users.update.flash.error'))
        expect(response.status).to eq(200)
        expect(response).to render_template(:edit)
        expect(assigns(:user).id).to eq(student_user.id)
      end
    end

    describe "DELETE 'destroy'" do
      it 'should be OK if deleting normal user' do
        delete :destroy, id: student_user.id
        expect_delete_success_with_model('user', users_url)
      end
    end

    describe "GET 'preview_csv_upload'" do
      #TODO Test CSV Files Upload
      xit 'should redirect to root' do
        post :preview_csv_upload, id: 1
        expect_bounce_as_not_allowed
      end
    end

    describe "GET 'import_csv_upload'" do
      #TODO Test CSV Files Upload
      xit 'should redirect to root' do
        post :import_csv_upload, id: 1
        expect_bounce_as_not_allowed
      end
    end

    describe "GET 'user_personal_details'" do
      it 'should redirect to root' do
        get :user_personal_details, user_id: student_user.id
        expect(flash[:success]).to be_nil
        expect(flash[:error]).to be_nil
        expect(response.status).to eq(200)
        expect(response).to render_template(:user_personal_details)
      end
    end

    describe "GET 'user_subscription_status'" do
      it 'should redirect to root' do
        get :user_subscription_status, user_id: student_user.id
        expect(flash[:success]).to be_nil
        expect(flash[:error]).to be_nil
        expect(response.status).to eq(200)
        expect(response).to render_template(:user_subscription_status)
      end
    end

    describe "GET 'user_enrollments_details'" do
      it 'should redirect to root' do
        get :user_enrollments_details, user_id: student_user.id
        expect(flash[:success]).to be_nil
        expect(flash[:error]).to be_nil
        expect(response.status).to eq(200)
        expect(response).to render_template(:user_enrollments_details)
      end
    end

    describe "GET 'user_purchases_details'" do
      it 'should redirect to root' do
        get :user_purchases_details, user_id: student_user.id
        expect(flash[:success]).to be_nil
        expect(flash[:error]).to be_nil
        expect(response.status).to eq(200)
        expect(response).to render_template(:user_purchases_details)
      end
    end

    describe "GET 'user_courses_status'" do
      #TODO Need to build a HABTM for tutors and subject_courses
      xit 'should redirect to root' do
        get :user_courses_status, user_id: tutor_user.id
        expect(flash[:success]).to be_nil
        expect(flash[:error]).to be_nil
        expect(response.status).to eq(200)
        expect(response).to render_template(:user_courses_status)
      end
    end

    describe "POST 'update_courses'" do
      it 'should redirect to root' do
        patch :update_courses, user_id: tutor_user.id
        expect(flash[:error]).to be_nil
        expect(flash[:success]).to eq(I18n.t('controllers.users.update_subjects.flash.success'))
        expect(response.status).to eq(302)
        expect(response).to redirect_to(users_url)
      end
    end

  end

  context 'Logged in as a admin_user' do

    before(:each) do
      activate_authlogic
      UserSession.create!(admin_user)
    end

    describe "GET 'index'" do
      it 'should successfully render index' do
        get :index
        expect_index_success_with_model('users', User.all.count)
      end
    end

    describe "GET 'show'" do
      it 'should successfully render show' do
        get :show, id: student_user.id
        expect_show_success_with_model('user', student_user.id)
      end
    end

    describe "GET 'edit/1'" do
      it 'should successfully render edit' do
        get :edit, id: student_user.id
        expect_edit_success_with_model('user', student_user.id)
      end
    end

    describe "GET 'new'" do
      it 'should successfully render new' do
        get :new
        expect_new_success_with_model('user')
      end
    end

    describe "POST 'create'" do
      it 'should successfully create record' do
        post :create, user: valid_params
        expect_create_success_with_model('user', users_url)
        expect(assigns(:user).password_change_required).to eq(true)
      end
    end

    describe "PUT 'update'" do
      it 'should respond OK to valid params' do
        put :update, id: student_user.id, user: update_params
        expect_update_success_with_model('user', users_url)
      end

      it 'should reject invalid params' do
        put :update, id: student_user.id, user: {email: 'a'}
        expect(flash[:success]).to be_nil
        expect(flash[:error]).to eq(I18n.t('controllers.users.update.flash.error'))
        expect(response.status).to eq(200)
        expect(response).to render_template(:edit)
        expect(assigns(:user).id).to eq(student_user.id)
      end
    end

    describe "DELETE 'destroy'" do
      it 'should be OK if deleting normal user' do
        delete :destroy, id: student_user.id
        expect_delete_success_with_model('user', users_url)
      end
    end

    describe "GET 'preview_csv_upload'" do
      #TODO Test CSV Files Upload
      xit 'should redirect to root' do
        post :preview_csv_upload, id: 1
        expect_bounce_as_not_allowed
      end
    end

    describe "GET 'import_csv_upload'" do
      #TODO Test CSV Files Upload
      xit 'should redirect to root' do
        post :import_csv_upload, id: 1
        expect_bounce_as_not_allowed
      end
    end

    describe "GET 'user_personal_details'" do
      it 'should redirect to root' do
        get :user_personal_details, user_id: student_user.id
        expect(flash[:success]).to be_nil
        expect(flash[:error]).to be_nil
        expect(response.status).to eq(200)
        expect(response).to render_template(:user_personal_details)
      end
    end

    describe "GET 'user_subscription_status'" do
      it 'should redirect to root' do
        get :user_subscription_status, user_id: student_user.id
        expect(flash[:success]).to be_nil
        expect(flash[:error]).to be_nil
        expect(response.status).to eq(200)
        expect(response).to render_template(:user_subscription_status)
      end
    end

    describe "GET 'user_enrollments_details'" do
      it 'should redirect to root' do
        get :user_enrollments_details, user_id: student_user.id
        expect(flash[:success]).to be_nil
        expect(flash[:error]).to be_nil
        expect(response.status).to eq(200)
        expect(response).to render_template(:user_enrollments_details)
      end
    end

    describe "GET 'user_purchases_details'" do
      it 'should redirect to root' do
        get :user_purchases_details, user_id: student_user.id
        expect(flash[:success]).to be_nil
        expect(flash[:error]).to be_nil
        expect(response.status).to eq(200)
        expect(response).to render_template(:user_purchases_details)
      end
    end

    describe "GET 'user_courses_status'" do
      #TODO Need to build a HABTM for tutors and subject_courses
      xit 'should redirect to root' do
        get :user_courses_status, user_id: tutor_user.id
        expect(flash[:success]).to be_nil
        expect(flash[:error]).to be_nil
        expect(response.status).to eq(200)
        expect(response).to render_template(:user_courses_status)
      end
    end

    describe "POST 'update_courses'" do
      it 'should redirect to root' do
        patch :update_courses, user_id: tutor_user.id
        expect(flash[:error]).to be_nil
        expect(flash[:success]).to eq(I18n.t('controllers.users.update_subjects.flash.success'))
        expect(response.status).to eq(302)
        expect(response).to redirect_to(users_url)
      end
    end

  end

end
