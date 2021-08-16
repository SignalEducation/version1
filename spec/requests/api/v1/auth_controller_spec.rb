# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Api::V1::AuthController, type: :request do
  let!(:user)          { create(:user) }
  let!(:active_bearer) { create(:bearer, :active) }

  # login
  describe 'post /api/v1/auth/login' do
    context 'login a valid user' do
      before do
        post api_v1_auth_login_path,
             params: { user: { email: user.email, password: '123123123' } },
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
                                                  subscription_plan_category
                                                  token
                                                  user_credentials])

      end
    end

    context 'try to login a invalid email information' do
      before do
        post api_v1_auth_login_path,
             params: { user: { email: 'invalid_email@test.com', password: '123123123' } },
             headers: { Authorization: "Bearer #{active_bearer.api_key}" }
      end

      it 'returns HTTP status 404' do
        expect(response).to have_http_status 404
      end

      it 'returns error message data' do
        body = JSON.parse(response.body)

        expect(body['error']).to eq('No user registered with this email.')
      end
    end

    context 'try to login with a wrong password' do
      before do
        post api_v1_auth_login_path,
             params: { user: { email: user.email, password: 'no_valid_password' } },
             headers: { Authorization: "Bearer #{active_bearer.api_key}" }
      end

      it 'returns HTTP status 422' do
        expect(response).to have_http_status 422
      end

      it 'returns error message data' do
        body = JSON.parse(response.body)

        expect(body['error']).to eq('Invalid password.')
      end
    end
  end

  # logout
  describe 'post /api/v1/auth/logout' do
    context 'logout a valid user' do
      before do
        allow_any_instance_of(described_class).to receive(:current_user_session).and_return(user)
        allow_any_instance_of(User).to receive(:destroy).and_return(true)

        payload = described_class.new.send(:payload, user)
        token   = described_class.new.send(:encode_token, payload)

        post api_v1_auth_logout_path,
               headers: { Authorization: "Bearer #{active_bearer.api_key}", token: token }
      end

      it 'returns HTTP status 200' do
        expect(response).to have_http_status 200
      end

      it 'returns success json message' do
        body = JSON.parse(response.body)

        expect(body['message']).to eq('You have successfully logged out.')
      end
    end

    context 'try to logout a invalid user_session' do
      before do
        allow_any_instance_of(described_class).to receive(:current_user_session).and_return(user)
        allow_any_instance_of(User).to receive(:destroy).and_return(false)

        payload = described_class.new.send(:payload, user)
        token   = described_class.new.send(:encode_token, payload)

        post api_v1_auth_logout_path,
               headers: { Authorization: "Bearer #{active_bearer.api_key}", token: token }
      end

      it 'returns HTTP status 422' do
        expect(response).to have_http_status 422
      end

      it 'returns success json message' do
        body = JSON.parse(response.body)

        expect(body['error']).to eq('Unsuccessfull attempt to logout.')
      end
    end

    context 'try to logout a witn a blocked token' do
      let(:blocked_token) { create(:jwt_blocked_token) }

      before do
         post api_v1_auth_logout_path,
               headers: { Authorization: "Bearer #{active_bearer.api_key}", token: blocked_token.token }
      end

      it 'returns HTTP status 401' do
        expect(response).to have_http_status 401
      end

      it 'returns error message data' do
        body = JSON.parse(response.body)

        expect(body['message']).to eq('User not logged in. Please log in.')
      end
    end
  end
end
