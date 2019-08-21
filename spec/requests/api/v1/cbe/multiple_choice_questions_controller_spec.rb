require 'rails_helper'

RSpec.describe 'Api::V1::Cbe::MultipleChoiceQuestionsController', type: :request do
  let(:cbe_section) { create(:cbe_section, :with_cbe) }

  describe 'get /api/v1/cbe/multiple_choice_questions' do
    context 'return all records' do
      let!(:multiple_choice_questions) { create_list(:cbe_multiple_choice_question, 5,:with_cbe_section) }

      before { get '/api/v1/cbe/multiple_choice_questions' }

      it 'returns HTTP status 200' do
        expect(response).to have_http_status 200
      end

      it 'returns multiple_choice_questions json data' do
        body = JSON.parse(response.body)

        expect(body.size).to eq(5)
        expect(body.map { |j| j['id'] }).to match_array(multiple_choice_questions.pluck(:id))
        expect(body.map { |j| j['name'] }).to match_array(multiple_choice_questions.pluck(:name))
        expect(body.map(&:keys).uniq).to contain_exactly(%w[id
                                                            label
                                                            order
                                                            name
                                                            question_1
                                                            question_2
                                                            question_3
                                                            question_4
                                                            correct_answer
                                                            cbe_section])
      end
    end

    context 'return an empty record' do
      before { get '/api/v1/cbe/multiple_choice_questions' }

      it 'returns HTTP status 200' do
        expect(response).to have_http_status 200
      end

      it 'returns empty data' do
        body = JSON.parse(response.body)
        expect(body).to be_empty
      end
    end
  end

  describe 'post /api/v1/cbe/multiple_choice_questions' do
    context 'create a valid CBE multiple_choice_questions' do
      let(:multiple_choice_questions) { build(:cbe_multiple_choice_question, :with_cbe_section) }

      before do
        post '/api/v1/cbe/multiple_choice_questions',
             params: { cbe_multiple_choice_question: multiple_choice_questions.attributes }
      end

      it 'returns HTTP status 200' do
        expect(response).to have_http_status 200
      end

      it 'returns multiple_choice_question json data' do
        body = JSON.parse(response.body)

        expect(body['label']).to eq(multiple_choice_questions.label)
        expect(body['order']).to eq(multiple_choice_questions.order)
        expect(body['name']).to eq(multiple_choice_questions.name)
        expect(body['question_1']).to eq(multiple_choice_questions.question_1)
        expect(body['question_2']).to eq(multiple_choice_questions.question_2)
        expect(body['question_3']).to eq(multiple_choice_questions.question_3)
        expect(body['question_4']).to eq(multiple_choice_questions.question_4)
        expect(body['correct_answer']).to eq(multiple_choice_questions.correct_answer)

        expect([body.keys]).to contain_exactly(%w[id
                                                  label
                                                  order
                                                  name
                                                  question_1
                                                  question_2
                                                  question_3
                                                  question_4
                                                  correct_answer
                                                  cbe_section])
      end
    end

    context 'try to create a invalid CBE section' do
      let(:multiple_choice_questions) { build(:cbe_multiple_choice_question) }

      before do
        post '/api/v1/cbe/multiple_choice_questions',
             params: { cbe_multiple_choice_question: multiple_choice_questions.attributes }
      end

      it 'returns HTTP status 422' do
        expect(response).to have_http_status 422
      end

      it 'returns empty data' do
        body = JSON.parse(response.body)

        expect(body['errors']).to eq('cbe_section' => ['must exist'])
      end
    end
  end
end
