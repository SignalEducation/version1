# frozen_string_literal: true

require 'rails_helper'

RSpec.describe 'Api::V1::Cbe::QuestionsController', type: :request do
  let(:cbe) { create(:cbe) }

  context 'for cbe_sections' do
    let(:cbe_section) { create(:cbe_section, cbe: cbe) }
    describe "get /api/v1/sections/:cbe_section_id/questions" do
      context 'return all records' do
        let!(:questions) { create_list(:cbe_question, 5, section: cbe_section) }

        before { get "/api/v1/sections/#{cbe_section.id}/questions" }

        it 'returns HTTP status 200' do
          expect(response).to have_http_status 200
        end

        it 'returns questions json data' do
          body = JSON.parse(response.body)

          expect(body.size).to eq(5)
          expect(body.map { |j| j['id'] }).to match_array(questions.pluck(:id))
          expect(body.map { |j| j['name'] }).to match_array(questions.pluck(:name))
          expect(body.map(&:keys).uniq).to contain_exactly(%w[id
                                                              kind
                                                              content
                                                              solution
                                                              score
                                                              sorting_order
                                                              section_id
                                                              answers
                                                              scenario])
        end
      end

      context 'return an empty record' do
        before { get "/api/v1/sections/#{cbe_section.id}/questions" }

        it 'returns HTTP status 200' do
          expect(response).to have_http_status 200
        end

        it 'returns empty data' do
          body = JSON.parse(response.body)
          expect(body).to be_empty
        end
      end
    end

    describe 'post /api/v1/sections/:cbe_section_id/questions' do
      context 'create a valid CBE questions' do
        let(:question) { build(:cbe_question) }

        before do
          post "/api/v1/sections/#{cbe_section.id}/questions",
               params: { question: question.attributes }
        end

        it 'returns HTTP status 200' do
          expect(response).to have_http_status 200
        end

        it 'returns multiple_choice_question json data' do
          body = JSON.parse(response.body)

          expect(body['kind']).to eq(question.kind)
          expect(body['content']).to eq(question.content)
          expect(body['score']).to eq(question.score)

          expect([body.keys]).to contain_exactly(%w[id
                                                    kind
                                                    content
                                                    solution
                                                    score
                                                    sorting_order
                                                    section_id
                                                    answers
                                                    scenario])
        end
      end

      context 'try to create a invalid CBE question' do
        let(:question) { build(:cbe_question) }

        before do
          question.content = nil
          post "/api/v1/sections/#{cbe_section.id}/questions",
               params: { question: question.attributes }
        end

        it 'returns HTTP status 422' do
          expect(response).to have_http_status 422
        end

        it 'returns empty data' do
          body = JSON.parse(response.body)

          expect(body['errors']).to eq("content"=>["can't be blank"])
        end
      end
    end
  end

  context 'for cbe_scenarios' do
    let(:cbe_scenario) { create(:cbe_scenario, :with_section) }

    describe "get /api/v1/scenarios/:cbe_scenario_id/questions" do
      context 'return all records' do
        let!(:questions) { create_list(:cbe_question, 5, scenario: cbe_scenario, section: cbe_scenario.section) }

        before { get "/api/v1/scenarios/#{cbe_scenario.id}/questions" }

        it 'returns HTTP status 200' do
          expect(response).to have_http_status 200
        end

        it 'returns questions json data' do
          body = JSON.parse(response.body)

          expect(body.size).to eq(5)
          expect(body.map { |j| j['id'] }).to match_array(questions.pluck(:id))
          expect(body.map { |j| j['name'] }).to match_array(questions.pluck(:name))
          expect(body.map(&:keys).uniq).to contain_exactly(%w[id
                                                              kind
                                                              content
                                                              solution
                                                              score
                                                              sorting_order
                                                              section_id
                                                              answers
                                                              scenario])
        end
      end

      context 'return an empty record' do
        before { get "/api/v1/scenarios/#{cbe_scenario.id}/questions" }

        it 'returns HTTP status 200' do
          expect(response).to have_http_status 200
        end

        it 'returns empty data' do
          body = JSON.parse(response.body)
          expect(body).to be_empty
        end
      end
    end

    describe 'post /api/v1/scenarios/:cbe_scenario_id/questions' do
      context 'create a valid CBE questions' do
        let(:question) { build(:cbe_question, scenario: cbe_scenario, section: cbe_scenario.section) }

        before do
          post "/api/v1/scenarios/#{cbe_scenario.id}/questions",
               params: { question: question.attributes }
        end

        it 'returns HTTP status 200' do
          expect(response).to have_http_status 200
        end

        it 'returns multiple_choice_question json data' do
          body = JSON.parse(response.body)

          expect(body['kind']).to eq(question.kind)
          expect(body['content']).to eq(question.content)
          expect(body['score']).to eq(question.score)

          expect([body.keys]).to contain_exactly(%w[id
                                                    kind
                                                    content
                                                    solution
                                                    score
                                                    sorting_order
                                                    section_id
                                                    answers
                                                    scenario])
        end
      end

      context 'try to create a invalid CBE question' do
        let(:question) { build(:cbe_question, scenario: cbe_scenario, section: cbe_scenario.section) }

        before do
          question.content = nil
          post "/api/v1/scenarios/#{cbe_scenario.id}/questions",
               params: { question: question.attributes }
        end

        it 'returns HTTP status 422' do
          expect(response).to have_http_status 422
        end

        it 'returns empty data' do
          body = JSON.parse(response.body)

          expect(body['errors']).to eq("content"=>["can't be blank"])
        end
      end
    end
  end

  describe 'patch /api/v1/questions/:id' do
    context 'update a valid CBE questions' do
      let(:question)       { create(:cbe_question, :with_section, :with_answers) }
      let(:answers)        { attributes_for_list(:cbe_answer, 3) }
      let!(:update_params) { FactoryBot.attributes_for(:cbe_question, kind: 'multiple_choice', answers_attributes: answers) }

      before do
        patch "/api/v1/questions/#{question.id}", params: { question: update_params }
      end

      it 'returns HTTP status 200' do
        expect(response).to have_http_status 200
      end

      it 'returns cbes json data' do
        body = JSON.parse(response.body)

        expect(body['kind']).to eq(update_params[:kind])
        expect(body['content']).to eq(update_params[:content])
        expect(body['score']).to eq(update_params[:score])

        expect([body.keys]).to contain_exactly(%w[id
                                                  kind
                                                  content
                                                  solution
                                                  score
                                                  sorting_order
                                                  section_id
                                                  answers
                                                  scenario])
      end
    end

    context 'try to update an invalid CBE question' do
      let(:question) { create(:cbe_question, :with_section) }
      let(:answers)        { attributes_for_list(:cbe_answer, 3) }
      let!(:update_params) { FactoryBot.attributes_for(:cbe_question, content: '', answers_attributes: answers) }

      before do
        question.content = nil
        patch "/api/v1/questions/#{question.id}",
             params: { question: update_params }
      end

      it 'returns HTTP status 422' do
        expect(response).to have_http_status 422
      end

      it 'returns empty data' do
        body = JSON.parse(response.body)

        expect(body['errors']).to eq('content'=>["can't be blank"])
      end
    end
  end

  context 'for cbe_scenarios' do
    let(:cbe_scenario) { create(:cbe_scenario, :with_section) }

    describe "get /api/v1/scenarios/:cbe_scenario_id/questions" do
      context 'return all records' do
        let!(:questions) { create_list(:cbe_question, 5, scenario: cbe_scenario, section: cbe_scenario.section) }

        before { get "/api/v1/scenarios/#{cbe_scenario.id}/questions" }

        it 'returns HTTP status 200' do
          expect(response).to have_http_status 200
        end

        it 'returns questions json data' do
          body = JSON.parse(response.body)

          expect(body.size).to eq(5)
          expect(body.map { |j| j['id'] }).to match_array(questions.pluck(:id))
          expect(body.map { |j| j['name'] }).to match_array(questions.pluck(:name))
          expect(body.map(&:keys).uniq).to contain_exactly(%w[id
                                                              kind
                                                              content
                                                              solution
                                                              score
                                                              sorting_order
                                                              section_id
                                                              answers
                                                              scenario])
        end
      end

      context 'return an empty record' do
        before { get "/api/v1/scenarios/#{cbe_scenario.id}/questions" }

        it 'returns HTTP status 200' do
          expect(response).to have_http_status 200
        end

        it 'returns empty data' do
          body = JSON.parse(response.body)
          expect(body).to be_empty
        end
      end
    end

    describe 'post /api/v1/scenarios/:cbe_scenario_id/questions' do
      context 'create a valid CBE questions' do
        let(:question) { build(:cbe_question, scenario: cbe_scenario, section: cbe_scenario.section) }

        before do
          post "/api/v1/scenarios/#{cbe_scenario.id}/questions",
               params: { question: question.attributes }
        end

        it 'returns HTTP status 200' do
          expect(response).to have_http_status 200
        end

        it 'returns multiple_choice_question json data' do
          body = JSON.parse(response.body)

          expect(body['kind']).to eq(question.kind)
          expect(body['content']).to eq(question.content)
          expect(body['score']).to eq(question.score)

          expect([body.keys]).to contain_exactly(%w[id
                                                    kind
                                                    content
                                                    solution
                                                    score
                                                    sorting_order
                                                    section_id
                                                    answers
                                                    scenario])
        end
      end

      context 'try to create a invalid CBE question' do
        let(:question) { build(:cbe_question, scenario: cbe_scenario, section: cbe_scenario.section) }

        before do
          question.content = nil
          post "/api/v1/scenarios/#{cbe_scenario.id}/questions",
               params: { question: question.attributes }
        end

        it 'returns HTTP status 422' do
          expect(response).to have_http_status 422
        end

        it 'returns empty data' do
          body = JSON.parse(response.body)

          expect(body['errors']).to eq('content' => ["can't be blank"])
        end
      end
    end
  end

  describe 'post /api/v1/questions/:id' do
    context 'destroy a CBE question' do
      let(:cbe_section) { create(:cbe_section, cbe: cbe) }
      let(:question) { create(:cbe_question, section: cbe_section) }

      before do
        delete "/api/v1/questions/#{question.id}"
      end

      it 'returns HTTP status 202' do
        expect(response).to have_http_status 202
      end
    end
  end
end
