require 'rails_helper'

RSpec.describe 'Api::V1::SubjectCoursesController', type: :request do
  describe 'get /api/v1/subject_courses' do
    context 'return all records' do
      let!(:subject_courses) { create_list(:active_subject_course, 5) }

      before { get '/api/v1/subject_courses' }

      it 'returns HTTP status 200' do
        expect(response).to have_http_status 200
      end

      it 'returns subject_courses json data' do
        body = JSON.parse(response.body)

        expect(body.size).to eq(5)
        expect(body.map { |j| j['value'] }).to match_array(subject_courses.pluck(:id))
        expect(body.map { |j| j['text'] }).to match_array(subject_courses.pluck(:name))
      end
    end

    context 'return an empty record' do
      before { get '/api/v1/subject_courses' }

      it 'returns HTTP status 200' do
        expect(response).to have_http_status 200
      end

      it 'returns empty data' do
        body = JSON.parse(response.body)
        expect(body).to be_empty
      end
    end
  end
end
