# frozen_string_literal: true

require 'rails_helper'

RSpec.describe 'Api::V1::PracticeQuestionsController', type: :request do
  let(:step) { build(:course_step) }
  let!(:log) { build(:course_step_log, id: 1, is_practice_question: true, course_step: step, course_lesson_log_id: 1) }

  # show
  describe 'get  /api/v1/course_step_log/:course_step_log_id/practice_questions/:id' do
    context 'return CoursePracticeQuestion data' do
      let!(:practice_question) { create(:course_practice_question, course_step: step) }

      before do
        allow(CourseStepLog).to receive(:find).and_return(log)
        get "/api/v1/course_step_log/#{log.id}/practice_questions/#{practice_question.id}"
      end

      it 'returns HTTP status 200' do
        expect(response).to have_http_status 200
      end

      it 'returns cbes json data' do
        body = JSON.parse(response.body)

        expect(body['id']).to eq(practice_question.id)
        expect(body['name']).to eq(practice_question.name)
        expect(body['content']).to eq(practice_question.content)
        expect(body['document']['name']).to eq(practice_question.document_file_name)
        expect(body['document']['url']).to eq(practice_question.document.url(:original, timestamp: false))
        expect([body.keys]).to contain_exactly(%w[id kind name content course_step total_questions document questions responses exhibits solutions_v2])
      end
    end

    context 'return not found data' do
      before { get "/api/v1/course_step_log/#{log.id}/practice_questions/id" }

      it 'returns HTTP status 404' do
        expect(response).to have_http_status 404
      end

      it 'returns cbes json data' do
        body = JSON.parse(response.body)
        expect(body['errors']).to include("Couldn't find CoursePracticeQuestion with")
        expect([body.keys]).to contain_exactly(['errors'])
      end
    end
  end

  # update
  describe 'PATCH /api/v1/course_step_log/:course_step_log_id/practice_questions/:id' do
    let(:practice_question) { create(:course_practice_question, course_step: step) }

    let!(:log) do
      allow_any_instance_of(CourseStepLog).to receive(:set_booleans).and_return(true)
      allow_any_instance_of(CourseStepLog).to receive(:update_course_lesson_log).and_return(true)

      create(:course_step_log, :skip_validate, is_practice_question: true)
    end

    context 'responses data' do
      let!(:update_params) { attributes_for(:practice_question_responses) }
      let!(:response_obj) do
        create(:practice_question_responses,
          course_step_log: log,
          practice_question: practice_question)
      end

      context 'return updated PracticeQuestion:Response data' do
        before do
          update_params[:id] = response_obj.id

          patch "/api/v1/course_step_log/#{log.id}/practice_questions/#{practice_question.id}", params: { responses: [update_params] }
        end

        it 'returns HTTP status 200' do
          expect(response).to have_http_status 200
        end

        it 'returns cbes json data' do
          body = JSON.parse(response.body)
          data = body['responses'].first

          expect(data['id']).to eq(update_params[:id])
          expect(data['content']['text']).to eq(update_params[:content][:text])
          expect([data.keys]).to contain_exactly(%w[id sorting_order kind content practice_question_id])
        end
      end

      context 'return error data' do
        before do
          allow_any_instance_of(Api::V1::PracticeQuestionsController).to receive(:update_practice_question_responses).and_return(false)

          update_params[:id] = response_obj.id

          patch "/api/v1/course_step_log/#{log.id}/practice_questions/#{practice_question.id}", params: { responses: [update_params] }
        end

        it 'returns HTTP status 422' do
          expect(response).to have_http_status 422
        end

        it 'returns error data' do
          body = JSON.parse(response.body)

          expect(body['errors']).to be_empty
          expect([body.keys]).to contain_exactly(['errors'])
        end
      end
    end

    context 'answers data' do
      let!(:update_params) { attributes_for(:practice_question_answers) }
      let!(:question)      { create(:practice_question_questions, practice_question: practice_question) }
      let!(:answer_obj)    { create(:practice_question_answers, question: question, course_step_log: log) }

      context 'return updated PracticeQuestion:Response data' do
        before do
          update_params[:answer_id]      = answer_obj.id
          update_params[:answer_content] = update_params[:content]

          patch "/api/v1/course_step_log/#{log.id}/practice_questions/#{practice_question.id}", params: { practice_questions: [update_params] }
        end

        it 'returns HTTP status 200' do
          expect(response).to have_http_status 200
        end

        it 'returns cbes json data' do
          body = JSON.parse(response.body)
          data = body['questions'].first

          expect(data['answer_id']).to eq(update_params[:answer_id])
          expect(data['answer_content']['text']).to eq(update_params[:answer_content][:text])
          expect([data.keys]).to contain_exactly(%w[id name sorting_order kind description content solution practice_question_id answer_id answer_content current])
        end
      end

      context 'return error data' do
        before do
          allow_any_instance_of(Api::V1::PracticeQuestionsController).to receive(:update_practice_question_answers).and_return(false)

          update_params[:answer_id]      = answer_obj.id
          update_params[:answer_content] = update_params[:content]

          patch "/api/v1/course_step_log/#{log.id}/practice_questions/#{practice_question.id}", params: { practice_questions: [update_params] }
        end

        it 'returns HTTP status 422' do
          expect(response).to have_http_status 422
        end

        it 'returns error data' do
          body = JSON.parse(response.body)

          expect(body['errors']).to be_empty
          expect([body.keys]).to contain_exactly(['errors'])
        end
      end
    end
  end
end
