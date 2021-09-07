# frozen_string_literal: true

require 'rails_helper'

RSpec.describe 'Api::V1::ExamBodiesController', type: :request do
  let!(:exam_bodies)   { create_list(:exam_body, 5) }
  let!(:active_bearer) { create(:bearer, :active) }

  # index
  describe 'post /api/v1/exam_bodies' do
    context 'list active exam bodies' do
      before do
        get api_v1_exam_bodies_path,
            headers: { Authorization: "Bearer #{active_bearer.api_key}" }
      end

      it 'returns HTTP status 200' do
        expect(response).to have_http_status 200
      end

      it 'returns exam bodies json list' do
        body             = JSON.parse(response.body)
        exam_bodies_hash = ExamBody.all_active.all_in_order.map { |eb| { id: eb.id, name: eb.name }.stringify_keys }

        expect(body).to eq(exam_bodies_hash)
      end
    end
  end
end
