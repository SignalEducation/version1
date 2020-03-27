# frozen_string_literal: true

require 'rails_helper'

RSpec.describe 'Api::V1::CoursesController', type: :request do
  describe 'get /api/v1/courses' do
    context 'return all records' do
      let!(:courses) { create_list(:active_course, 5) }

      before { get '/api/v1/courses' }

      it 'returns HTTP status 200' do
        expect(response).to have_http_status 200
      end

      it 'returns courses json data' do
        body = JSON.parse(response.body)

        expect(body.size).to eq(5)
        expect(body.map { |j| j['value'] }).to match_array(courses.pluck(:id))
        expect(body.map { |j| j['text'] }).to match_array(courses.pluck(:name))
      end
    end

    context 'return an empty record' do
      before { get '/api/v1/courses' }

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
