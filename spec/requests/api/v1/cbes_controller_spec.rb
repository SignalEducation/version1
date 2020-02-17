# frozen_string_literal: true

require 'rails_helper'

RSpec.describe 'Api::V1::CbesController', type: :request do
  # index
  describe 'get /api/v1/cbes' do
    context 'return all records' do
      let!(:cbes) { create_list(:cbe, 5) }

      before { get '/api/v1/cbes' }

      it 'returns HTTP status 200' do
        expect(response).to have_http_status 200
      end

      it 'returns cbes json data' do
        body = JSON.parse(response.body)

        expect(body.size).to eq(5)
        expect(body.map { |j| j['id'] }).to match_array(cbes.pluck(:id))
        expect(body.map { |j| j['name'] }).to match_array(cbes.pluck(:name))
        expect(body.map(&:keys).uniq).to contain_exactly(%w[id
                                                            name
                                                            title
                                                            content
                                                            agreement_content
                                                            active
                                                            score
                                                            subject_course_id
                                                            introduction_pages
                                                            resources
                                                            sections
                                                            questions
                                                            subject_course
                                                            exam_body])
      end
    end

    context 'return an empty record' do
      before { get '/api/v1/cbes' }

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
  describe 'get /api/v1/cbes/:id' do
    context 'return a CBE' do
      let!(:cbe) { create(:cbe) }

      before { get "/api/v1/cbes/#{cbe.id}" }

      it 'returns HTTP status 200' do
        expect(response).to have_http_status 200
      end

      it 'returns cbes json data' do
        body = JSON.parse(response.body)

        expect(body['id']).to eq(cbe.id)
        expect(body['name']).to eq(cbe.name)
        expect([body.keys]).to contain_exactly(%w[id
                                                  name
                                                  title
                                                  content
                                                  agreement_content
                                                  active
                                                  score
                                                  subject_course_id
                                                  introduction_pages
                                                  resources
                                                  sections
                                                  questions
                                                  subject_course
                                                  exam_body])
      end
    end
  end

  # create
  describe 'post /api/v1/cbes' do
    context 'create a valid cbe' do
      let(:cbe) { build(:cbe) }

      before do
        post '/api/v1/cbes', params: { cbe: cbe.attributes }
      end

      it 'returns HTTP status 200' do
        expect(response).to have_http_status 200
      end

      it 'returns cbes json data' do
        body = JSON.parse(response.body)

        expect(body['name']).to eq(cbe.name)
        expect(body['title']).to eq(cbe.title)
        expect(body['content']).to eq(cbe.content)
        expect([body.keys]).to contain_exactly(%w[id
                                                  name
                                                  title
                                                  content
                                                  agreement_content
                                                  active
                                                  score
                                                  subject_course_id
                                                  introduction_pages
                                                  resources
                                                  sections
                                                  questions
                                                  subject_course
                                                  exam_body])
      end
    end

    context 'try to create a invalid cbe' do
      let(:cbe) { build(:cbe, subject_course: nil) }

      before do
        post '/api/v1/cbes', params: { cbe: cbe.attributes }
      end

      it 'returns HTTP status 422' do
        expect(response).to have_http_status 422
      end

      it 'returns empty data' do
        body = JSON.parse(response.body)

        expect(body['errors']).to eq('subject_course' => ['must exist'], 'subject_course_id' => ['can\'t be blank'])
      end
    end
  end

  describe 'patch /api/v1/cbes/:id' do
    context 'update a cbe' do
      let!(:cbe) { create(:cbe) }
      let!(:update_params) { attributes_for(:cbe, name: 'Updated CBE') }

      before do
        patch "/api/v1/cbes/#{cbe.id}", params: { cbe: update_params }
      end

      it 'returns HTTP status 200' do
        expect(response).to have_http_status 200
      end

      it 'returns cbes json data' do
        body = JSON.parse(response.body)

        expect(body['name']).to eq(update_params[:name])
        expect(body['title']).to eq(update_params[:title])
        expect(body['content']).to eq(update_params[:content])
        expect([body.keys]).to contain_exactly(%w[id
                                                  name
                                                  title
                                                  content
                                                  agreement_content
                                                  active
                                                  score
                                                  subject_course_id
                                                  introduction_pages
                                                  resources
                                                  sections
                                                  questions
                                                  subject_course
                                                  exam_body])
      end
    end

    context 'try to update a cbe with invalid details' do
      let!(:cbe) { create(:cbe) }
      let!(:update_params) { FactoryBot.attributes_for(:cbe, subject_course_id: nil) }

      before do
        patch "/api/v1/cbes/#{cbe.id}", params: { cbe: update_params }
      end

      it 'returns HTTP status 422' do
        expect(response).to have_http_status 422
      end

      it 'returns empty data' do
        body = JSON.parse(response.body)

        expect(body['errors']).to eq('subject_course' => ['must exist'], 'subject_course_id' => ['can\'t be blank'])
      end
    end
  end
end
