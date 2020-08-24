# frozen_string_literal: true

require 'rails_helper'
require 'rack/test'

RSpec.describe 'Api::V1::Cbe::RequirementsController', type: :request do
  let(:scenario) { create(:cbe_scenario, :with_section) }

  describe 'POST /api/v1/scenarios/:scenario_id/requirements' do
    context 'create a valid CBE requirement' do
      let(:requirement) { build(:cbe_requirements, scenario: scenario) }

      before do
        post api_v1_scenario_requirements_path(scenario.id), params: { requirements: requirement.attributes }
      end

      it 'returns HTTP status 200' do
        expect(response).to have_http_status 200
      end

      it 'returns resource json data' do
        body = JSON.parse(response.body)

        expect(body['name']).to eq(requirement.name)
        expect(body['kind']).to eq(requirement.kind)
        expect(body['content']).to eq(requirement.content)
        expect(body['solution']).to eq(requirement.solution)
        expect(body['scenario_id']).to eq(scenario.id)
        expect(body['sorting_order']).to eq(requirement.sorting_order)
      end
    end

    context 'try to create a invalid CBE resource' do
      let!(:requirement) { build(:cbe_requirements) }

      before do
        requirement.name = nil
        post api_v1_scenario_requirements_path(scenario.id), params: { requirements: requirement.attributes }
      end

      it 'returns HTTP status 422' do
        expect(response).to have_http_status 422
      end

      it 'returns empty data' do
        body = JSON.parse(response.body)

        expect(body['errors']).to eq('name' => ['can\'t be blank'])
      end
    end
  end

  describe 'PATCH /api/v1/requirements/:id' do
    context 'update a valid CBE requirements' do
      let(:requirement) { create(:cbe_requirements, :with_scenario) }

      before do
        requirement.name = Faker::Lorem.word
        patch api_v1_requirement_path(requirement.id), params: { requirements: requirement.attributes }
      end

      it 'returns HTTP status 200' do
        expect(response).to have_http_status 200
      end

      it 'returns resource json data' do
        body = JSON.parse(response.body)

        expect(body['name']).to eq(requirement.name)
        expect(body['kind']).to eq(requirement.kind)
        expect(body['content']).to eq(requirement.content)
        expect(body['solution']).to eq(requirement.solution)
        expect(body['scenario_id']).to eq(requirement.scenario.id)
        expect(body['sorting_order']).to eq(requirement.sorting_order)
      end
    end

    context 'try to create a invalid CBE resource' do
      let!(:requirement) { create(:cbe_requirements, :with_scenario) }

      before do
        requirement.name = nil
        patch api_v1_requirement_path(requirement.id), params: { requirements: requirement.attributes }
      end

      it 'returns HTTP status 422' do
        expect(response).to have_http_status 422
      end

      it 'returns empty data' do
        body = JSON.parse(response.body)

        expect(body['errors']).to eq('name' => ['can\'t be blank'])
      end
    end
  end

  describe 'DELETE /api/v1/requirements/:id' do
    let(:requirement) { create(:cbe_requirements, :with_scenario) }

    context 'destroy a requirements' do
      before do
        delete api_v1_requirement_path(requirement.id)
      end

      it 'returns HTTP status 202' do
        body = JSON.parse(response.body)

        expect(response).to have_http_status 202
        expect(body['message']).to eq("Requirement #{requirement.id} was deleted.")
      end
    end

    context 'error when try to destroy a not valid CBE introduction_pages' do
      before do
        allow_any_instance_of(Cbe::Requirement).to receive(:destroy).and_return(false)
        delete api_v1_requirement_path(requirement.id)
      end

      it 'returns HTTP status 422' do
        expect(response).to have_http_status 422
      end
    end
  end
end
