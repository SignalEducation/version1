require 'rails_helper'

RSpec.describe 'Api::V1::CbesController', type: :request do
  describe 'get /api/v1/cbes' do
    context 'return all records' do
      let!(:cbes) { create_list(:cbe, 5, :with_subject_course) }

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
                                                            exam_time
                                                            hard_time_limit
                                                            number_of_pauses_allowed
                                                            length_of_pauses
                                                            agreement_content
                                                            active
                                                            score
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

  describe 'post /api/v1/cbes' do
    context 'create a valid cbe' do
      let(:cbe) { build(:cbe, :with_subject_course) }

      before do
        post '/api/v1/cbes', params: { cbe: cbe.attributes }
      end

      it 'returns HTTP status 200' do
        expect(response).to have_http_status 200
      end

      it 'returns cbes json data' do
        body = JSON.parse(response.body)

        expect(body['name']).to eq(cbe.name)
        #expect(body['title']).to eq(cbe.title)
        expect(body['content']).to eq(cbe.content)
        expect(body['exam_time']).to eq(cbe.exam_time)
        expect(body['hard_time_limit']).to eq(cbe.hard_time_limit)
        expect(body['number_of_pauses_allowed']).to eq(cbe.number_of_pauses_allowed)
        expect(body['length_of_pauses']).to eq(cbe.length_of_pauses)
        expect([body.keys]).to contain_exactly(%w[id
                                                  name
                                                  title
                                                  content
                                                  exam_time
                                                  hard_time_limit
                                                  number_of_pauses_allowed
                                                  length_of_pauses
                                                  agreement_content
                                                  active
                                                  score
                                                  subject_course
                                                  exam_body])
      end
    end

    context 'try to create a invalid cbe' do
      let(:cbe) { build(:cbe) }

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
end
