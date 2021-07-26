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

        expect(body['message']).to eq("User successfully created.")
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
end
