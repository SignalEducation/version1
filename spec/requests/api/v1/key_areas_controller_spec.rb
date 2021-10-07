# frozen_string_literal: true

require 'rails_helper'
require 'support/system_setup'

RSpec.describe Api::V1::KeyAreasController, type: :request do
  before do
    allow_any_instance_of(StripePlanService).to receive(:create_plan).and_return(true)
    allow_any_instance_of(PaypalPlansService).to receive(:create_plan).and_return(true)
  end

  # include_context 'system_setup'
  let!(:active_bearer) { create(:bearer, :active) }
  let!(:key_areas)     { create_list(:key_area, 5, :active) }

  # index
  describe 'post /api/v1/key_areas' do
    context 'list active all products and subscriptions plans' do
      before do
        key_areas.each{ |k| create_list(:active_course, 5, key_area: k) }

        get api_v1_key_areas_path,
            headers: { Authorization: "Bearer #{active_bearer.api_key}" }
      end

      it 'returns HTTP status 200' do
        expect(response).to have_http_status 200
      end

      it 'returns exam bodies and respective subscription plans and products json list' do
        body             = JSON.parse(response.body)
        key_areas_hash   = body['key_areas']
        key_areas_sample = key_areas_hash.sample

        expect(key_areas_hash.map{ |e| e['id'] }).to       include(key_areas_sample['id'])
        expect(key_areas_hash.map{ |e| e['name'] }).to     include(key_areas_sample['name'])
        expect(key_areas_hash.map{ |e| e['courses'] }).to  include(key_areas_sample['courses'])
        expect(key_areas_hash.map{ |e| e['group_id'] }).to include(key_areas_sample['group_id'])

        expect(key_areas_sample.keys).to include('id',
                                                 'name',
                                                 'courses',
                                                 'group_id')

      end
    end
  end
end
