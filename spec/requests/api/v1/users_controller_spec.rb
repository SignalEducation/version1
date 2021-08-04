# frozen_string_literal: true

require 'rails_helper'

RSpec.describe 'Api::V1::UsersController', type: :request do
  let!(:exam_body)       { create(:exam_body) }
  let!(:user_group)      { create(:student_user_group) }
  let!(:active_bearer)   { create(:bearer, :active) }
  let!(:inactive_bearer) { create(:bearer, :inactive) }

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
                                                  email_verification_code
                                                  email_verified_at
                                                  email_verified
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
                                                  subscription_plan_category])

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

    context 'Unauthorazied bearer' do
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
                                                  email_verification_code
                                                  email_verified_at
                                                  email_verified
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
                                                  subscription_plan_category])
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
end
