# frozen_string_literal: true

require 'rails_helper'
require 'rack/test'

RSpec.describe 'Api::V1::Cbe::ExhibitsController', type: :request do
  let(:scenario) { create(:cbe_scenario, :with_section) }

  describe 'POST /api/v1/scenarios/:scenario_id/exhibits' do
    context 'create a valid CBE pdf exhibit' do
      let(:exhibt) { build(:cbe_exhibits, :with_pdf, scenario: scenario) }
      let(:doc)    { Rack::Test::UploadedFile.new('spec/support/fixtures/file.pdf', 'application/pdf') }

      before do
        post api_v1_scenario_exhibits_path(scenario.id), params: { exhibits: exhibt.attributes.merge(document: doc) }
      end

      it 'returns HTTP status 200' do
        expect(response).to have_http_status 200
      end

      it 'returns resource json data' do
        body = JSON.parse(response.body)

        expect(body['name']).to eq(exhibt.name)
        expect(body['kind']).to eq(exhibt.kind)
        expect(body['scenario_id']).to eq(scenario.id)
        expect(body['sorting_order']).to eq(exhibt.sorting_order)
        expect(body['document']['name']).to eq(doc.original_filename)
      end
    end

    context 'create a valid CBE spreadsheet exhibit' do
      let(:exhibt) { build(:cbe_exhibits, :with_spreadsheet, scenario: scenario) }

      before do
        post api_v1_scenario_exhibits_path(scenario.id), params: { exhibits: exhibt.attributes }
      end

      it 'returns HTTP status 200' do
        expect(response).to have_http_status 200
      end

      it 'returns resource json data' do
        body = JSON.parse(response.body)

        expect(body['name']).to eq(exhibt.name)
        expect(body['kind']).to eq(exhibt.kind)
        expect(body['content']).to eq(JSON.parse(exhibt.content))
        expect(body['scenario_id']).to eq(scenario.id)
        expect(body['sorting_order']).to eq(exhibt.sorting_order)
      end
    end

    context 'try to create a invalid CBE resource' do
      let!(:exhibt) { build(:cbe_exhibits, :with_pdf) }

      before do
        exhibt.name = nil
        post api_v1_scenario_exhibits_path(scenario.id), params: { exhibits: exhibt.attributes }
      end

      it 'returns HTTP status 422' do
        expect(response).to have_http_status 422
      end

      it 'returns empty data' do
        body = JSON.parse(response.body)

        expect(body['errors']).to eq('document'=>["can't be blank"], 'name' => ['can\'t be blank'])
      end
    end
  end

  describe 'PATCH /api/v1/exhibits/:id' do
    context 'update a valid CBE exhibits' do
      let(:exhibt) { create(:cbe_exhibits, :with_pdf, :with_scenario) }

      before do
        exhibt.name = Faker::Lorem.word
        patch api_v1_exhibit_path(exhibt.id), params: { exhibits: exhibt.attributes }
      end

      it 'returns HTTP status 200' do
        expect(response).to have_http_status 200
      end

      it 'returns resource json data' do
        body = JSON.parse(response.body)

        expect(body['name']).to eq(exhibt.name)
        expect(body['kind']).to eq(exhibt.kind)
        expect(body['scenario_id']).to eq(exhibt.cbe_scenario_id)
        expect(body['sorting_order']).to eq(exhibt.sorting_order)
        expect(body['document']['name']).to eq(exhibt.document.original_filename)
      end
    end

    context 'try to create a invalid CBE resource' do
      let!(:exhibt) { create(:cbe_exhibits, :with_pdf, :with_scenario) }

      before do
        exhibt.name = nil
        patch api_v1_exhibit_path(exhibt.id), params: { exhibits: exhibt.attributes }
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

  describe 'DELETE /api/v1/exhibits/:id' do
    let(:exhibt) { create(:cbe_exhibits, :with_pdf, :with_scenario) }

    context 'destroy a exhibits' do
      before do
        delete api_v1_exhibit_path(exhibt.id)
      end

      it 'returns HTTP status 202' do
        body = JSON.parse(response.body)

        expect(response).to have_http_status 202
        expect(body['message']).to eq("Exhibit #{exhibt.id} was deleted.")
      end
    end

    context 'error when try to destroy a not valid CBE introduction_pages' do
      before do
        allow_any_instance_of(Cbe::Exhibit).to receive(:destroy).and_return(false)
        delete api_v1_exhibit_path(exhibt.id)
      end

      it 'returns HTTP status 422' do
        expect(response).to have_http_status 422
      end
    end
  end
end
