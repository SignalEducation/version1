# frozen_string_literal: true

require 'rails_helper'

RSpec.describe 'Api::V1::Cbe::UsersAnswerController', type: :request do
  let(:cbe)         { create(:cbe) }
  let(:user_answer) { create(:cbe_user_answer) }

  # show
  describe 'get /api/v1/cbes/#cbe_id/users_log/user_answer_id' do
    context 'return an user_log data' do
      before { get "/api/v1/cbes/#{cbe.id}/users_answer/#{user_answer.id}" }

      it 'returns HTTP status 200' do
        expect(response).to have_http_status 200
      end

      it 'returns a specific user log json data' do
        body = JSON.parse(response.body)

        expect(body['id']).to eq(user_answer.id)
        expect([body.keys]).to contain_exactly(%w[id
                                                  content])
      end
    end
  end
end
