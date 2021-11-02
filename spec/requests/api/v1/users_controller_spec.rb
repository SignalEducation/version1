# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Api::V1::UsersController, type: :request do
  let!(:exam_body)       { create(:exam_body) }
  let!(:user_group)      { create(:student_user_group) }
  let!(:active_bearer)   { create(:bearer, :active) }
  let!(:inactive_bearer) { create(:bearer, :inactive) }
  let(:user)             { create(:user) }

  before do
    allow_any_instance_of(User).to receive(:handle_post_user_creation).and_return(true)
    allow(UserGroup).to receive(:student_group).and_return(user_group)
  end

  # create
  describe 'post /api/v1/users' do
    context 'create a valid user' do
      let(:user_params) { attributes_for(:user, preferred_exam_body_id: exam_body.id) }

      before do
        post api_v1_users_path,
             params: { user: user_params },
             headers: { Authorization: "Bearer #{active_bearer.api_key}" }
      end

      it 'returns HTTP status 201' do
        expect(response).to have_http_status 201
      end

      it 'returns success json message' do
        body = JSON.parse(response.body)

        expect(body['first_name']).to eq(user_params[:first_name])
        expect(body['last_name']).to eq(user_params[:last_name])
        expect(body['email']).to eq(user_params[:email])
        expect([body.keys]).to contain_exactly(%w[id
                                                  name
                                                  first_name
                                                  last_name
                                                  email
                                                  active
                                                  address
                                                  user_group
                                                  guid
                                                  valid_subscription
                                                  email_verification_code
                                                  email_verified_at
                                                  email_verified
                                                  verify_remain_days
                                                  verify_email_message
                                                  show_verify_email_message
                                                  free_trial
                                                  terms_and_conditions
                                                  date_of_birth
                                                  description
                                                  analytics_guid
                                                  student_number
                                                  unsubscribed_from_emails
                                                  communication_approval
                                                  communication_approval_datetime
                                                  preferred_exam_body_id
                                                  currency_id
                                                  video_player
                                                  profile_image_file_name
                                                  profile_image_content_type
                                                  profile_image_file_size
                                                  profile_image_updated_at
                                                  country
                                                  currency
                                                  subscription_plan_category
                                                  subscriptions
                                                  token
                                                  user_credentials])

      end
    end

    context 'try to create a invalid user' do
      let(:user_params) { attributes_for(:user, password: nil) }

      before do
        post api_v1_users_path,
             params: { user: user_params },
             headers: { Authorization: "Bearer #{active_bearer.api_key}" }
      end

      it 'returns HTTP status 422' do
        expect(response).to have_http_status 422
      end

      it 'returns error message data' do
        body = JSON.parse(response.body)

        expect(body['error']).to eq("password"=>["can't be blank", "is too short (minimum is 6 characters)"], "password_confirmation"=>["doesn't match Password"])
      end
    end

    context 'Unauthorised bearer' do
      before do
        post api_v1_users_path,
             params: { user: 'anything here' },
             headers: { Authorization: "Bearer #{inactive_bearer.api_key}" }
      end

      it 'returns unauthorised HTTP status 401' do
        expect(response).to have_http_status 401
      end

      it 'returns unauthorised response' do
        expect(response.body).to eq("HTTP Token: Access denied.\n")
      end
    end
  end

  # show
  describe 'get /api/v1/users/:id' do
    context 'return a valid user' do
      let(:user) { create(:user, preferred_exam_body_id: exam_body.id) }

      before do
        get api_v1_user_path(id: user.id),
            headers: { Authorization: "Bearer #{active_bearer.api_key}" }
      end

      it 'returns HTTP status 200' do
        expect(response).to have_http_status 200
      end

      it 'returns success json message' do
        body = JSON.parse(response.body)

        expect(body['first_name']).to eq(user[:first_name])
        expect(body['last_name']).to eq(user[:last_name])
        expect(body['email']).to eq(user[:email])
        expect([body.keys]).to contain_exactly(%w[id
                                                  name
                                                  first_name
                                                  last_name
                                                  email
                                                  active
                                                  address
                                                  user_group
                                                  guid
                                                  valid_subscription
                                                  email_verification_code
                                                  email_verified_at
                                                  email_verified
                                                  verify_remain_days
                                                  verify_email_message
                                                  show_verify_email_message
                                                  free_trial
                                                  terms_and_conditions
                                                  date_of_birth
                                                  description
                                                  analytics_guid
                                                  student_number
                                                  unsubscribed_from_emails
                                                  communication_approval
                                                  communication_approval_datetime
                                                  preferred_exam_body_id
                                                  currency_id
                                                  video_player
                                                  profile_image_file_name
                                                  profile_image_content_type
                                                  profile_image_file_size
                                                  profile_image_updated_at
                                                  country
                                                  currency
                                                  subscription_plan_category
                                                  subscriptions])
      end
    end

    context 'return not found user message' do
      before do
        get api_v1_user_path(id: 9999999),
            headers: { Authorization: "Bearer #{active_bearer.api_key}" }
      end

      it 'returns HTTP status 404' do
        expect(response).to have_http_status 404
      end

      it 'returns success json message' do
        body = JSON.parse(response.body)

        expect(body['error']).to eq("Couldn't find User with 'id'=9999999")
      end
    end
  end

  # forgot_password
  describe 'get /api/v1/users/forgot_password' do
    context 'start a valid reset password process' do
      before do
        get forgot_password_api_v1_users_path(email: user.email),
            headers: { Authorization: "Bearer #{active_bearer.api_key}" }
      end

      it 'returns HTTP status 200' do
        expect(response).to have_http_status 200
      end

      it 'returns success json message' do
        body = JSON.parse(response.body)

        expect(body['message']).to eq("Check your mailbox for further instructions. If you don't receive an email from learnsignal within a couple of minutes, check your spam folder.")
      end
    end

    context 'reset password returns not found user' do
      let(:no_user_email) { 'no_user@test.com' }

      before do
        get forgot_password_api_v1_users_path(email: no_user_email),
            headers: { Authorization: "Bearer #{active_bearer.api_key}" }
      end

      it 'returns HTTP status 404' do
        expect(response).to have_http_status 404
      end

      it 'returns success json message' do
        body = JSON.parse(response.body)

        expect(body['message']).to eq('No registered user using this email.')
      end
    end

    context 'forgot password returns invalid email format' do
      let(:invalid_email) { 'invalid@test' }

      before do
        get forgot_password_api_v1_users_path(email: invalid_email),
            headers: { Authorization: "Bearer #{active_bearer.api_key}" }
      end

      it 'returns HTTP status 422' do
        expect(response).to have_http_status 422
      end

      it 'returns success json message' do
        body = JSON.parse(response.body)

        expect(body['message']).to eq('Invalid email format.')
      end
    end
  end

  # update
  describe 'patch get /api/v1/users/:id' do
    context 'update a user' do
      let!(:user) { create(:user) }
      let!(:update_params) { attributes_for(:user, first_name: 'Updated name', preferred_exam_body_id: exam_body.id) }

      before do
        allow_any_instance_of(described_class).to receive(:authorize_user).and_return(true)
        allow_any_instance_of(described_class).to receive(:same_user?).and_return(true)

        patch "/api/v1/users/#{user.id}",
          params: { user: update_params },
          headers: { Authorization: "Bearer #{active_bearer.api_key}" }
      end

      it 'returns HTTP status 200' do
        expect(response).to have_http_status 200
      end

      it 'returns user json data' do
        body = JSON.parse(response.body)

        expect(body['first_name']).to eq(update_params[:first_name])
        expect(body['last_name']).to eq(update_params[:last_name])
        expect(body['email']).to eq(update_params[:email])
        expect([body.keys]).to contain_exactly(%w[id
                                                  name
                                                  first_name
                                                  last_name
                                                  email
                                                  active
                                                  address
                                                  user_group
                                                  guid
                                                  valid_subscription
                                                  email_verification_code
                                                  email_verified_at
                                                  email_verified
                                                  verify_remain_days
                                                  verify_email_message
                                                  show_verify_email_message
                                                  free_trial
                                                  terms_and_conditions
                                                  date_of_birth
                                                  description
                                                  analytics_guid
                                                  student_number
                                                  unsubscribed_from_emails
                                                  communication_approval
                                                  communication_approval_datetime
                                                  preferred_exam_body_id
                                                  currency_id
                                                  video_player
                                                  profile_image_file_name
                                                  profile_image_content_type
                                                  profile_image_file_size
                                                  profile_image_updated_at
                                                  country
                                                  currency
                                                  subscription_plan_category
                                                  subscriptions])
      end
    end

    context 'try to update a user with invalid details' do
      let!(:user) { create(:user) }
      let!(:update_params) { attributes_for(:user, first_name: '', preferred_exam_body_id: exam_body.id) }

      before do
        allow_any_instance_of(described_class).to receive(:authorize_user).and_return(true)
        allow_any_instance_of(described_class).to receive(:same_user?).and_return(true)

        patch "/api/v1/users/#{user.id}",
          params: { user: update_params },
          headers: { Authorization: "Bearer #{active_bearer.api_key}" }
      end

      it 'returns HTTP status 422' do
        expect(response).to have_http_status 422
      end

      it 'returns empty data' do
        body = JSON.parse(response.body)
        expect(body['error']).to eq('first_name' => ['can\'t be blank', 'is too short (minimum is 2 characters)'])
      end
    end
  end

  # change_password
  describe 'post get /api/v1/users/:user_id/change_password' do
    context 'change user password' do
      let!(:user)            { create(:user) }
      let!(:password_params) { { current_password: '123123123', password: 'new_pass', password_confirmation: 'new_pass' } }

      before do
        allow_any_instance_of(described_class).to receive(:authorize_user).and_return(true)
        allow_any_instance_of(described_class).to receive(:same_user?).and_return(true)

        post "/api/v1/users/#{user.id}/change_password",
          params: { user: password_params },
          headers: { Authorization: "Bearer #{active_bearer.api_key}" }
      end

      it 'returns HTTP status 200' do
        expect(response).to have_http_status 200
      end

      it 'returns success json message' do
        body = JSON.parse(response.body)

        expect(body['message']).to eq(I18n.t('controllers.users.change_password.flash.success'))
      end
    end

    context 'fail in change user password' do
      let!(:user)            { create(:user) }
      let!(:password_params) { { current_password: 'no_passs', password: 'new_pass', password_confirmation: 'new_pass' } }

      before do
        allow_any_instance_of(described_class).to receive(:authorize_user).and_return(true)
        allow_any_instance_of(described_class).to receive(:same_user?).and_return(true)

        post "/api/v1/users/#{user.id}/change_password",
          params: { user: password_params },
          headers: { Authorization: "Bearer #{active_bearer.api_key}" }
      end

      it 'returns HTTP status 422' do
        expect(response).to have_http_status 422
      end

      it 'returns error json message' do
        body = JSON.parse(response.body)

        expect(body['message']).to eq(I18n.t('controllers.users.change_password.flash.error'))
      end
    end
  end

  # resend_verify_user_email
  describe 'get /api/v1/users/#user_id/resend_verify_user_email' do
    context 'resend verify user email' do
      before do
        allow_any_instance_of(User).to receive(:send_verification_email).and_return(true)
        get api_v1_user_resend_verify_user_email_path(user_id: user.id),
            headers: { Authorization: "Bearer #{active_bearer.api_key}" }
      end

      it 'returns HTTP status 200' do
        expect(response).to have_http_status 200
      end

      it 'returns success json message' do
        body = JSON.parse(response.body)

        expect(body['message']).to eq("A verification email was sent to #{user.email}.")
      end
    end

    context 'error when resend verify user email' do
      let(:no_user_email) { 'no_user@test.com' }

      before do
        get api_v1_user_resend_verify_user_email_path(user_id: user.id),
            headers: { Authorization: "Bearer #{active_bearer.api_key}" }
      end

      it 'returns HTTP status 422' do
        expect(response).to have_http_status 422
      end

      it 'returns success json message' do
        body = JSON.parse(response.body)

        expect(body['error']).to eq("An error ocurred when tried to send e verification email to #{user.email}.")
      end
    end

    context 'not found a user' do
      let(:invalid_user_id) { rand(100..999) }

      before do
        get api_v1_user_resend_verify_user_email_path(user_id: invalid_user_id),
            headers: { Authorization: "Bearer #{active_bearer.api_key}" }
      end

      it 'returns HTTP status 422' do
        expect(response).to have_http_status 404
      end

      it 'returns success json message' do
        body = JSON.parse(response.body)

        expect(body['error']).to eq("Couldn't find User with 'id'=#{invalid_user_id}")
      end
    end
  end
end
