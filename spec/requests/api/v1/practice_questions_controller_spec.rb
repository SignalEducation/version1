# frozen_string_literal: true

require 'rails_helper'

RSpec.describe 'Api::V1::PracticeQuestionsController', type: :request do
  let!(:step) { build(:course_step) }

  # index
  describe 'get /api/v1/practice_questions' do
    context 'return all records' do
      let!(:practice_questions) { create_list(:course_practice_question, 5, course_step: step) }

      before { get '/api/v1/practice_questions' }

      it 'returns HTTP status 200' do
        expect(response).to have_http_status 200
      end

      it 'returns cbes json data' do
        body = JSON.parse(response.body)

        expect(body.size).to eq(5)
        expect(body.map { |j| j['id'] }).to match_array(practice_questions.pluck(:id))
        expect(body.map { |j| j['name'] }).to match_array(practice_questions.pluck(:name))
        expect(body.map { |j| j['content'] }).to match_array(practice_questions.pluck(:content))
        expect(body.map(&:keys).uniq).to contain_exactly(%w[id kind name content course_step total_questions questions])
      end
    end

    context 'return an empty record' do
      before { get '/api/v1/practice_questions' }

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
  describe 'get /api/v1/practice_questions/:id' do
    context 'return CoursePracticeQuestion data' do
      let!(:practice_question) { create(:course_practice_question, course_step: step) }

      before { get "/api/v1/practice_questions/#{practice_question.id}" }

      it 'returns HTTP status 200' do
        expect(response).to have_http_status 200
      end

      it 'returns cbes json data' do
        body = JSON.parse(response.body)

        expect(body['id']).to eq(practice_question.id)
        expect(body['name']).to eq(practice_question.name)
        expect(body['content']).to eq(practice_question.content)
        expect([body.keys]).to contain_exactly(%w[id kind name content course_step total_questions questions])
      end
    end

    context 'return not found data' do
      before { get "/api/v1/practice_questions/id" }

      it 'returns HTTP status 404' do
        expect(response).to have_http_status 404
      end

      it 'returns cbes json data' do
        body = JSON.parse(response.body)
        expect(body['error']).to include("Couldn't find CoursePracticeQuestion with")
        expect([body.keys]).to contain_exactly(['error'])
      end
    end
  end
end
