# frozen_string_literal: true

require 'rails_helper'

RSpec.describe 'Api::V1::Cbe::UsersLogController', type: :request do
  let(:cbe)  { create(:cbe, :with_subject_course) }
  let(:user) { create(:user) }

  # index
  describe 'get /api/v1/cbes/#cbe_id/users_log' do
    context 'return all records' do
      let!(:users_log) { create_list(:cbe_user_log, 5, :with_answers, :started, cbe: cbe) }

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
                                                            user
                                                            answers
                                                            cbe])
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
      let!(:user_log) { create(:cbe_user_log, :with_answers, :paused, cbe: cbe) }

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
                                                  user
                                                  answers
                                                  cbe])
        expect(body['answers'].map { |a| a['text'] }).to include(user_log.answers.sample.content['text'])
      end
    end
  end

  # create
  describe 'post /api/v1/cbes/#cbe_id/users_log' do
    context 'create a valid UserLog' do
      let(:user_log) { build(:cbe_user_log, :with_answers, :finished, cbe: cbe, user: user) }

      before do
        params = user_log.attributes.merge(answers_attributes: user_log.answers.map(&:attributes))
        post "/api/v1/cbes/#{cbe.id}/users_log", params: { cbe_user_log: params }
      end

      it 'returns HTTP status 200' do
        expect(response).to have_http_status 200
      end

      it 'returns the user log json data' do
        body = JSON.parse(response.body)

        expect(body['status']).to eq('finished')
        expect([body.keys]).to contain_exactly(%w[id
                                                status
                                                user
                                                answers
                                                cbe])
        expect(body['answers'].map { |a| a['text'] }).to include(user_log.answers.sample.content['text'])
      end
    end

    context 'try to create a invalid user log' do
      let(:user_log) { build(:cbe_user_log, :with_answers, :finished) }

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
end
