# frozen_string_literal: true

require 'rails_helper'

RSpec.describe 'Api::V1::Cbe::UsersLogController', type: :request do
  let(:cbe)      { create(:cbe) }
  let(:user)     { create(:user) }
  let(:exercise) { create(:exercise) }

  before do
    allow_any_instance_of(SlackService).to receive(:notify_channel).and_return(false)
    allow_any_instance_of(Exercise).to receive(:correction_returned_email).and_return(false)
  end

  # index
  describe 'get /api/v1/cbes/#cbe_id/users_log' do
    context 'return all records' do
      let!(:users_log) { create_list(:cbe_user_log, 5, :started, cbe: cbe, exercise: exercise) }

      before { get "/api/v1/cbes/#{cbe.id}/users_log" }

      it 'returns HTTP status 200' do
        expect(response).to have_http_status 200
      end

      it 'returns users log json data' do
        body = JSON.parse(response.body)

        expect(body.size).to eq(5)
        expect(body.map { |j| j['id'] }).to eq(users_log.pluck(:id))
        expect(body.map { |j| j['status'] }).to match_array(users_log.pluck(:status))
        expect(body.map { |j| j['status'] }.sample).to eq('started')
        expect(body.map(&:keys).uniq).to contain_exactly(%w[id
                                                            status
                                                            score
                                                            agreed
                                                            current_state
                                                            scratch_pad
                                                            pages_state
                                                            user
                                                            cbe
                                                            user_questions
                                                            user_responses])
      end
    end

    context 'return an empty record' do
      before { get "/api/v1/cbes/#{cbe.id}/users_log" }

      it 'returns HTTP status 200' do
        expect(response).to have_http_status 200
      end

      it 'returns empty data' do
        body = JSON.parse(response.body)
        expect(body).to be_empty
      end
    end
  end

  # show
  describe 'get /api/v1/cbes/#cbe_id/users_log/user_log_id' do
    context 'return an user_log data' do
      let!(:user_log) { create(:cbe_user_log, :paused, cbe: cbe, exercise: exercise) }

      before { get "/api/v1/cbes/#{cbe.id}/users_log/#{user_log.id}" }

      it 'returns HTTP status 200' do
        expect(response).to have_http_status 200
      end

      it 'returns a specific user log json data' do
        body = JSON.parse(response.body)

        expect(body['id']).to eq(user_log.id)
        expect(body['status']).to eq('paused')
        expect([body.keys]).to contain_exactly(%w[id
                                                  status
                                                  score
                                                  agreed
                                                  current_state
                                                  scratch_pad
                                                  pages_state
                                                  user
                                                  cbe
                                                  user_questions
                                                  user_responses])
      end
    end
  end

  # create
  describe 'post /api/v1/cbes/#cbe_id/users_log' do
    context 'create a valid UserLog' do
      let(:user_log) { build(:cbe_user_log, :finished, cbe: cbe, user: user, exercise: exercise) }

      before do
        params = user_log.attributes
        post "/api/v1/cbes/#{cbe.id}/users_log", params: { cbe_user_log: params.to_h }
      end

      it 'returns HTTP status 200' do
        expect(response).to have_http_status 200
      end

      it 'returns the user log json data' do
        body = JSON.parse(response.body)

        expect(body['status']).to eq('finished')
        expect([body.keys]).to contain_exactly(%w[id
                                                  status
                                                  score
                                                  agreed
                                                  current_state
                                                  scratch_pad
                                                  pages_state
                                                  user
                                                  cbe
                                                  user_questions
                                                  user_responses])
      end
    end

    context 'try to create a invalid user log' do
      let(:user_log) { build(:cbe_user_log, :finished) }

      before do
        post "/api/v1/cbes/#{cbe.id}/users_log", params: { cbe_user_log: user_log.attributes }
      end

      it 'returns HTTP status 422' do
        expect(response).to have_http_status 422
      end

      it 'returns empty data' do
        body = JSON.parse(response.body)

        expect(body['errors']).to eq('user' => ['must exist'], 'cbe' => ['must exist'], 'cbe_id' => ['can\'t be blank'])
      end
    end
  end

  # update
  describe 'post /api/v1/cbes/#cbe_id/users_log/:id' do
    context 'create a valid UserLog' do
      let(:user_log)       { create(:cbe_user_log, :started, cbe: cbe, user: user, exercise: exercise) }
      let!(:update_params) { attributes_for(:cbe_user_log, :finished) }

      before do
        patch "/api/v1/cbes/#{cbe.id}/users_log/#{user_log.id}", params: { cbe_user_log: update_params }
      end

      it 'returns HTTP status 200' do
        expect(response.status).to eq(200)
      end

      it 'returns the user log json data' do
        body = JSON.parse(response.body)

        expect(body['status']).to eq('finished')
        expect([body.keys]).to contain_exactly(%w[id
                                                  status
                                                  score
                                                  agreed
                                                  current_state
                                                  scratch_pad
                                                  pages_state
                                                  user
                                                  cbe
                                                  user_questions
                                                  user_responses])
      end
    end

    context 'try to create a invalid user log' do
      let(:user_log)       { create(:cbe_user_log, :started, cbe: cbe, user: user) }
      let!(:update_params) { attributes_for(:cbe_user_log, user_id: nil, cbe_id: nil ) }

      before do
        patch "/api/v1/cbes/#{cbe.id}/users_log/#{user_log.id}", params: { cbe_user_log: update_params }
      end

      it 'returns HTTP status 422' do
        expect(response).to have_http_status 422
      end

      it 'returns empty data' do
        body = JSON.parse(response.body)

        expect(body['errors']).to eq('user' => ['must exist'], 'cbe' => ['must exist'], 'cbe_id' => ['can\'t be blank'])
      end
    end
  end

  # user_agreement
  describe 'post /api/v1/cbes/:cbe_id/users_log/:users_log_id/user_agreement' do
    let(:user_log) { create(:cbe_user_log, :started, cbe: cbe, user: user, exercise: exercise) }

    context 'update agreement in UserLog' do
      before do
        post "/api/v1/cbes/#{cbe.id}/users_log/#{user_log.id}/user_agreement",
             params: { id: user_log.id, cbe_id: cbe.id, users_log_id: user_log.id, cbe_user_log: { agreed: true } }
      end

      it 'returns HTTP status 200' do
        expect(response.status).to eq(200)
      end

      it 'returns the user log json data' do
        body = JSON.parse(response.body)

        expect(body['message']).to eq('User log updated successfully.')
      end
    end

    context 'try to create a invalid user log' do
      before do
        allow_any_instance_of(::Cbe::UserLog).to receive(:update).and_return(false)

        post "/api/v1/cbes/#{cbe.id}/users_log/#{user_log.id}/user_agreement",
             params: { id: user_log.id, cbe_id: cbe.id, users_log_id: user_log.id, cbe_user_log: { agreed: true } }
      end

      it 'returns HTTP status 422' do
        expect(response).to have_http_status 422
      end

      it 'returns error data' do
        body = JSON.parse(response.body)
        expect(body.keys).to contain_exactly('errors')
      end
    end
  end

  # current_state
  describe 'post /api/v1/cbes/:cbe_id/users_log/:users_log_id/current_state' do
    let(:user_log) { create(:cbe_user_log, :started, cbe: cbe, user: user, exercise: exercise) }

    context 'update agreement in UserLog' do
      before do
        post "/api/v1/cbes/#{cbe.id}/users_log/#{user_log.id}/current_state",
             params: { id: user_log.id, cbe_id: cbe.id, users_log_id: user_log.id, cbe_user_log: { current_state: 'state' } }
      end

      it 'returns HTTP status 200' do
        expect(response.status).to eq(200)
      end

      it 'returns the user log json data' do
        body = JSON.parse(response.body)

        expect(body['message']).to eq('User log updated successfully.')
      end
    end

    context 'try to create a invalid user log' do
      before do
        allow_any_instance_of(::Cbe::UserLog).to receive(:update).and_return(false)

        post "/api/v1/cbes/#{cbe.id}/users_log/#{user_log.id}/current_state",
             params: { id: user_log.id, cbe_id: cbe.id, users_log_id: user_log.id, cbe_user_log: { current_state: 'state' } }
      end

      it 'returns HTTP status 422' do
        expect(response).to have_http_status 422
      end

      it 'returns error data' do
        body = JSON.parse(response.body)
        expect(body.keys).to contain_exactly('errors')
      end
    end
  end
end
