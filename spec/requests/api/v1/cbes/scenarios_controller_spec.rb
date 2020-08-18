# frozen_string_literal: true

require 'rails_helper'

RSpec.describe 'Api::V1::Cbe::ScenariosController', type: :request do
  let!(:cbe) { create(:cbe) }
  let(:cbe_section) { create(:cbe_section, cbe: cbe) }
  let(:cbe_scenario) { create(:cbe_scenario, cbe_section: cbe_section) }

  describe 'post /api/v1/cbe/scenarios' do
    context 'create a valid CBE scenario' do
      let(:scenario) { build(:cbe_scenario) }

      before do
        post "/api/v1/sections/#{cbe_section.id}/scenarios", params: { scenario: scenario.attributes }
      end

      it 'returns HTTP status 200' do
        expect(response).to have_http_status 200
      end

      it 'returns scenario json data' do
        body = JSON.parse(response.body)

        expect(body['content']).to eq(scenario.content)

        expect(body.keys).to include('id',
                                     'name',
                                     'content',
                                     'section_id',
                                     'questions',
                                     'section_questions')
      end
    end

    context 'try to create a invalid CBE scenario' do
      let(:scenario) { build(:cbe_scenario, content: '') }

      before do
        post "/api/v1/sections/#{cbe_section.id}/scenarios", params: { scenario: scenario.attributes }
      end

      it 'returns HTTP status 422' do
        expect(response).to have_http_status 422
      end

      it 'returns empty data' do
        body = JSON.parse(response.body)

        expect(body['errors']).to eq("content"=>["can't be blank"])
      end
    end
  end

  describe 'patch /api/v1/scenarios/:id' do
    context 'update a valid CBE scenarios' do
      let(:scenario) { create(:cbe_scenario, :with_section) }
      let!(:update_params) { FactoryBot.attributes_for(:scenario, content: 'Scenario content text') }

      before do
        patch "/api/v1/scenarios/#{scenario.id}", params: { scenario: update_params }
      end

      it 'returns HTTP status 200' do
        expect(response).to have_http_status 200
      end

      it 'returns scenario json data' do
        body = JSON.parse(response.body)

        expect(body['content']).to eq(update_params[:content])

        expect(body.keys).to include('id',
                                     'name',
                                     'content',
                                     'section_id',
                                     'questions',
                                     'section_questions')
      end
    end

    context 'try to create a invalid CBE section' do
      let(:scenario) { create(:cbe_scenario, :with_section) }
      let!(:update_params) { FactoryBot.attributes_for(:cbe_scenario, content: nil) }

      before do
        patch "/api/v1/scenarios/#{scenario.id}", params: { scenario: update_params }
      end

      it 'returns HTTP status 422' do
        expect(response).to have_http_status 422
      end

      it 'returns empty data' do
        body = JSON.parse(response.body)

        expect(body['errors']).to eq("content"=>["can't be blank"])
      end
    end
  end

  describe 'post /api/v1/scenarios/:id' do
    context 'destroy a CBE scenario' do
      let(:scenario) { create(:cbe_scenario, :with_section) }

      before do
        delete "/api/v1/scenarios/#{scenario.id}"
      end

      it 'returns HTTP status 202' do
        expect(response).to have_http_status 202
      end
    end

    context 'error when try to destroy a not valid CBE scenario' do
      let(:scenario) { create(:cbe_scenario, :with_section) }

      before do
        allow_any_instance_of(Cbe::Scenario).to receive(:destroy).and_return(false)
        delete "/api/v1/scenarios/#{scenario.id}"
      end

      it 'returns HTTP status 202' do
        expect(response).to have_http_status 422
      end
    end
  end
end
