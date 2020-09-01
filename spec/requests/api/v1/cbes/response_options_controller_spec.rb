# frozen_string_literal: true

require 'rails_helper'
require 'rack/test'

RSpec.describe 'Api::V1::Cbe::ResponseOptionsController', type: :request do
  let(:scenario) { create(:cbe_scenario, :with_section) }

  describe 'POST /api/v1/scenarios/:scenario_id/response_options' do
    context 'create a valid CBE response_option' do
      let(:response_option) { build(:cbe_response_options, scenario: scenario) }

      before do
        post api_v1_scenario_response_options_path(scenario.id), params: { response_options: response_option.attributes }
      end

      it 'returns HTTP status 200' do
        expect(response).to have_http_status 200
      end

      it 'returns resource json data' do
        body = JSON.parse(response.body)

        expect(body['kind']).to eq(response_option.kind)
        expect(body['quantity']).to eq(response_option.quantity)
        expect(body['scenario_id']).to eq(scenario.id)
        expect(body['sorting_order']).to eq(response_option.sorting_order)
      end
    end

    context 'try to create a invalid CBE resource' do
      let!(:response_option) { build(:cbe_response_options) }

      before do
        response_option.sorting_order = nil
        post api_v1_scenario_response_options_path(scenario.id), params: { response_options: response_option.attributes }
      end

      it 'returns HTTP status 422' do
        expect(response).to have_http_status 422
      end

      it 'returns empty data' do
        body = JSON.parse(response.body)

        expect(body['errors']).to eq('sorting_order' => ['can\'t be blank'])
      end
    end
  end

  describe 'PATCH /api/v1/response_options/:id' do
    context 'update a valid CBE response_options' do
      let(:response_option) { create(:cbe_response_options, :with_scenario) }

      before do
        response_option.kind = Cbe::ResponseOption.kinds.keys.sample
        patch api_v1_response_option_path(response_option.id), params: { response_options: response_option.attributes }
      end

      it 'returns HTTP status 200' do
        expect(response).to have_http_status 200
      end

      it 'returns resource json data' do
        body = JSON.parse(response.body)

        expect(body['kind']).to eq(response_option.kind)
        expect(body['quantity']).to eq(response_option.quantity)
        expect(body['scenario_id']).to eq(response_option.scenario.id)
        expect(body['sorting_order']).to eq(response_option.sorting_order)
      end
    end

    context 'try to create a invalid CBE resource' do
      let!(:response_option) { create(:cbe_response_options, :with_scenario) }

      before do
        response_option.sorting_order = nil
        patch api_v1_response_option_path(response_option.id), params: { response_options: response_option.attributes }
      end

      it 'returns HTTP status 422' do
        expect(response).to have_http_status 422
      end

      it 'returns empty data' do
        body = JSON.parse(response.body)

        expect(body['errors']).to eq('sorting_order' => ['can\'t be blank'])
      end
    end
  end

  describe 'DELETE /api/v1/response_options/:id' do
    let(:response_option) { create(:cbe_response_options, :with_scenario) }

    context 'destroy a response_options' do
      before do
        allow_any_instance_of(Cbe::ResponseOption).to receive(:destroy).and_return(true)
        delete api_v1_response_option_path(response_option.id)
      end

      it 'returns HTTP status 202' do
        body = JSON.parse(response.body)

        expect(response).to have_http_status 202
        expect(body['message']).to eq("Response Option #{response_option.id} was deleted.")
      end
    end

    context 'error when try to destroy a not valid CBE introduction_pages' do
      before do
        allow_any_instance_of(Cbe::ResponseOption).to receive(:destroy).and_return(false)
        delete api_v1_response_option_path(response_option.id)
      end

      it 'returns HTTP status 422' do
        expect(response).to have_http_status 422
      end
    end
  end
end
