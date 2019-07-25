# == Schema Information
#
# Table name: users
#
#  id                              :integer          not null, primary key
#  email                           :string
#  first_name                      :string
#  last_name                       :string
#  address                         :text
#  country_id                      :integer
#  crypted_password                :string(128)      default(""), not null
#  password_salt                   :string(128)      default(""), not null
#  persistence_token               :string
#  perishable_token                :string(128)
#  single_access_token             :string
#  login_count                     :integer          default(0)
#  failed_login_count              :integer          default(0)
#  last_request_at                 :datetime
#  current_login_at                :datetime
#  last_login_at                   :datetime
#  current_login_ip                :string
#  last_login_ip                   :string
#  account_activation_code         :string
#  account_activated_at            :datetime
#  active                          :boolean          default(FALSE), not null
#  user_group_id                   :integer
#  password_reset_requested_at     :datetime
#  password_reset_token            :string
#  password_reset_at               :datetime
#  stripe_customer_id              :string
#  created_at                      :datetime
#  updated_at                      :datetime
#  locale                          :string
#  guid                            :string
#  subscription_plan_category_id   :integer
#  password_change_required        :boolean
#  session_key                     :string
#  name_url                        :string
#  profile_image_file_name         :string
#  profile_image_content_type      :string
#  profile_image_file_size         :integer
#  profile_image_updated_at        :datetime
#  email_verification_code         :string
#  email_verified_at               :datetime
#  email_verified                  :boolean          default(FALSE), not null
#  stripe_account_balance          :integer          default(0)
#  free_trial                      :boolean          default(FALSE)
#  terms_and_conditions            :boolean          default(FALSE)
#  date_of_birth                   :date
#  description                     :text
#  analytics_guid                  :string
#  student_number                  :string
#  unsubscribed_from_emails        :boolean          default(FALSE)
#  communication_approval          :boolean          default(FALSE)
#  communication_approval_datetime :datetime
#

require 'rails_helper'
require 'support/stripe_web_mock_helpers'

describe UsersController, type: :controller do
  before :each do
    allow_any_instance_of(SubscriptionPlanService).to receive(:queue_async)
  end

  let!(:student_user_group)        { create(:student_user_group) }
  let!(:basic_student)             { create(:basic_student, user_group_id: student_user_group.id) }
  let(:user_management_user_group) { create(:user_management_user_group) }
  let(:user_management_user)       { create(:user_management_user, user_group_id: user_management_user_group.id) }
  let(:unverified_student_user)    { create(:unverified_user, user_group_id: student_user_group.id) }
  let!(:exam_body_1)               { create(:exam_body) }
  let!(:group_1)                   { create(:group, exam_body_id: exam_body_1.id) }
  let!(:gbp)                       { create(:gbp) }
  let!(:uk)                        { create(:uk, currency: gbp) }
  let!(:uk_vat_code)               { create(:vat_code, country: uk) }
  let!(:uk_vat_rate)               { create(:vat_rate, vat_code: uk_vat_code) }

  let!(:subscription_plan_gbp_m) do
    create(:student_subscription_plan_m, currency: gbp, price: 7.50, stripe_guid: 'stripe_plan_guid_m', payment_frequency_in_months: 3)
  end

  let!(:valid_subscription) do
    create(:valid_subscription, user: basic_student, subscription_plan: subscription_plan_gbp_m, stripe_customer_id: basic_student.stripe_customer_id )
  end

  let!(:valid_params)              { attributes_for(:student_user, user_group_id: student_user_group.id) }
  let!(:update_params)             { attributes_for(:student_user, user_group_id: student_user_group.id) }

  context 'Logged in as a user_management_user' do
    before(:each) do
      activate_authlogic
      UserSession.create!(user_management_user)
    end

    describe "GET 'index'" do
      it 'should successfully render index' do
        get :index
        expect_index_success_with_model('users', User.all.count)
      end
    end

    describe "GET 'show'" do
      it 'should successfully render show' do
        get :show, params: { id: basic_student.id }
        expect_show_success_with_model('user', basic_student.id)
      end
    end

    describe "GET 'edit/1'" do
      it 'should successfully render edit' do
        get :edit, params: { id: basic_student.id }
        expect_edit_success_with_model('user', basic_student.id)
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
        stripe_url = 'https://api.stripe.com/v1/customers'
        stripe_request_body = {'email'=>valid_params[:email]}
        stub_customer_create_request(stripe_url, stripe_request_body)

        post :create, params: { user: valid_params }
        expect_create_success_with_model('user', users_url)
        expect(assigns(:user).password_change_required).to eq(true)
      end
    end

    describe "PUT 'update'" do
      it 'should respond OK to valid params' do
        put :update, params: { id: basic_student.id, user: update_params }
        expect_update_success_with_model('user', users_url)
      end

      it 'should reject invalid params' do
        put :update, params: { id: basic_student.id, user: {email: 'a'} }
        expect(flash[:success]).to be_nil
        expect(flash[:error]).to eq(I18n.t('controllers.users.update.flash.error'))
        expect(response.status).to eq(200)
        expect(response).to render_template(:edit)
        expect(assigns(:user).id).to eq(basic_student.id)
      end
    end

    describe "DELETE 'destroy'" do
      it 'should be OK if deleting normal user' do
        delete :destroy, params: { id: unverified_student_user.id }
        expect_delete_success_with_model('user', users_url)
      end
    end

    describe "GET 'search'" do
      it 'should successfully render a list of users' do
        get :search, xhr: true, params: { search_term: basic_student.email }
        users = assigns(:users)

        expect(response.successful?).to be_truthy
        expect(users).to include(basic_student)
        expect(users).not_to include(user_management_user)
      end
    end

    describe "GET 'preview_csv_upload'" do
      #TODO Test CSV Files Upload
      xit 'should redirect to root' do
        post :preview_csv_upload, params: { id: 1 }
        expect_bounce_as_not_allowed
      end
    end

    describe "GET 'import_csv_upload'" do
      #TODO Test CSV Files Upload
      xit 'should redirect to root' do
        post :import_csv_upload, params: { id: 1 }
        expect_bounce_as_not_allowed
      end
    end

    describe "GET 'user_personal_details'" do
      it 'should redirect to root' do
        get :user_personal_details, params: { user_id: basic_student.id }
        expect(flash[:success]).to be_nil
        expect(flash[:error]).to be_nil
        expect(response.status).to eq(200)
        expect(response).to render_template(:user_personal_details)
      end
    end

    describe "GET 'user_subscription_status'" do
      it 'should redirect to root' do
        get :user_subscription_status, params: { user_id: basic_student.id }
        expect(flash[:success]).to be_nil
        expect(flash[:error]).to be_nil
        expect(response.status).to eq(200)
        expect(response).to render_template(:user_subscription_status)
      end
    end

    describe "GET 'user_activity_details'" do
      it 'should redirect to root' do
        get :user_activity_details, params: { user_id: basic_student.id }
        expect(flash[:success]).to be_nil
        expect(flash[:error]).to be_nil
        expect(response.status).to eq(200)
        expect(response).to render_template(:user_activity_details)
      end
    end

    describe "GET 'user_purchases_details'" do
      it 'should redirect to root' do
        get :user_purchases_details, params: { user_id: basic_student.id }
        expect(flash[:success]).to be_nil
        expect(flash[:error]).to be_nil
        expect(response.status).to eq(200)
        expect(response).to render_template(:user_purchases_details)
      end
    end
  end
end
