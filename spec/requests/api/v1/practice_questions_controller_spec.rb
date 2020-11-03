# frozen_string_literal: true

require 'rails_helper'

RSpec.describe 'Api::V1::PracticeQuestionsController', type: :request do
  let(:step) { build(:course_step) }
  let!(:log)  { build(:course_step_log, id: 1, is_practice_question: true, course_step: step) }

  # show
  describe 'get  /api/v1/course_step_log/:course_step_log_id/practice_questions/:id' do
    context 'return CoursePracticeQuestion data' do
      let!(:practice_question) { create(:course_practice_question, course_step: step) }

      before do
        allow(CourseStepLog).to receive(:find).and_return(log)
        get "/api/v1/course_step_log/#{log.id}/practice_questions/#{practice_question.id}"
      end

      xit 'returns HTTP status 200' do
        expect(response).to have_http_status 200
      end

      xit 'returns cbes json data' do
        binding.pry
        body = JSON.parse(response.body)

        expect(body['id']).to eq(practice_question.id)
        expect(body['name']).to eq(practice_question.name)
        expect(body['content']).to eq(practice_question.content)
        expect([body.keys]).to contain_exactly(%w[id kind name content course_step total_questions questions])
      end
    end

    context 'return not found data' do
      before { get "/api/v1/course_step_log/#{log.id}/practice_questions/id" }

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
