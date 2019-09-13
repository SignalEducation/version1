# frozen_string_literal: true

require 'rails_helper'

RSpec.describe 'Api::V1::Cbe::QuestionsController', type: :request do
  let!(:cbe) { create(:cbe, :with_subject_course) }
  let(:cbe_section) { create(:cbe_section, cbe: cbe) }

  describe 'get /api/v1/cbes/questions' do
    context 'return all records' do
      let!(:questions) { create_list(:cbe_question, 5, section: cbe_section) }

      before { get "/api/v1/cbes/#{cbe.id}/questions" }

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
                                                            score
                                                            sorting_order
                                                            section_id
                                                            scenario])
      end
    end

    context 'return an empty record' do
      before { get "/api/v1/cbes/#{cbe.id}/questions" }

      it 'returns HTTP status 200' do
        expect(response).to have_http_status 200
      end

      it 'returns empty data' do
        body = JSON.parse(response.body)
        expect(body).to be_empty
      end
    end
  end

  describe 'post /api/v1/cbe/questions' do
    context 'create a valid CBE questions' do
      let(:questions) { build(:cbe_question, :with_section) }

      before do
        post "/api/v1/cbes/#{cbe.id}/questions",
             params: { question: questions.attributes }
      end

      it 'returns HTTP status 200' do
        expect(response).to have_http_status 200
      end

      it 'returns multiple_choice_question json data' do
        body = JSON.parse(response.body)

        expect(body['kind']).to eq(questions.kind)
        expect(body['content']).to eq(questions.content)
        expect(body['score']).to eq(questions.score)

        expect([body.keys]).to contain_exactly(%w[id
                                                  kind
                                                  content
                                                  score
                                                  sorting_order
                                                  section_id
                                                  scenario])
      end
    end

    context 'try to create a invalid CBE section' do
      let(:questions) { build(:cbe_question) }

      before do
        post "/api/v1/cbes/#{cbe.id}/questions",
             params: { question: questions.attributes }
      end

      it 'returns HTTP status 422' do
        expect(response).to have_http_status 422
      end

      it 'returns empty data' do
        body = JSON.parse(response.body)

        expect(body['errors']).to eq("cbe_section_id"=>["can't be blank"], "section"=>["must exist"])
      end
    end
  end
end
