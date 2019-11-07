# frozen_string_literal: true

require 'rails_helper'
require 'rack/test'

RSpec.describe 'Api::V1::Cbe::ResourcesController', type: :request do
  let(:cbe) { create(:cbe) }

  describe 'get /api/v1/cbes/:cbe_id/resources' do
    context 'return all records' do
      let!(:resources) { create_list(:cbe_resource, 5, cbe: cbe) }

      before { get "/api/v1/cbes/#{cbe.id}/resources" }

      it 'returns HTTP status 200' do
        expect(response).to have_http_status 200
      end

      it 'returns resources json data' do
        body = JSON.parse(response.body)

        expect(body.size).to eq(5)
        expect(body.map { |j| j['id'] }).to match_array(resources.pluck(:id))
        expect(body.map { |j| j['name'] }).to match_array(resources.pluck(:name))
      end
    end

    context 'return an empty record' do
      before { get "/api/v1/cbes/#{cbe.id}/resources" }

      it 'returns HTTP status 200' do
        expect(response).to have_http_status 200
      end

      it 'returns empty data' do
        body = JSON.parse(response.body)
        expect(body).to be_empty
      end
    end
  end

  describe 'post /api/v1/cbe/:cbe_id/resources/:id' do
    context 'update a valid CBE resource' do
      let(:resource) { create(:cbe_resource, cbe: cbe) }
      let(:doc) { Rack::Test::UploadedFile.new('spec/support/fixtures/file.pdf', 'application/pdf') }

      before do
        patch "/api/v1/cbes/#{cbe.id}/resources/#{resource.id}", params: { resource: { name: 'New Name' } }
      end

      it 'returns HTTP status 200' do
        expect(response).to have_http_status 200
      end

      it 'returns resource json data' do
        body = JSON.parse(response.body)

        expect(body['name']).to eq('New Name')
        expect(body['sorting_order']).to eq(resource.sorting_order)
      end
    end

    context 'try to update an invalid CBE resource' do
      let(:resource) { create(:cbe_resource) }

      before do
        resource.name = nil
        patch "/api/v1/cbes/#{cbe.id}/resources/#{resource.id}", params: { resource: resource.attributes }
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

  describe 'patch /api/v1/cbe/resources' do
    context 'create a valid CBE resource' do
      let(:resource) { build(:cbe_resource, cbe: cbe) }
      let(:doc) { Rack::Test::UploadedFile.new('spec/support/fixtures/file.pdf', 'application/pdf') }

      before do
        post "/api/v1/cbes/#{cbe.id}/resources", params: { resource: resource.attributes.merge(document: doc) }
      end

      it 'returns HTTP status 200' do
        expect(response).to have_http_status 200
      end

      it 'returns resource json data' do
        body = JSON.parse(response.body)

        expect(body['name']).to eq(resource.name)
      end
    end

    context 'try to create a invalid CBE resource' do
      let(:resource) { build(:cbe_resource) }

      before do
        resource.name = nil
        post "/api/v1/cbes/#{cbe.id}/resources", params: { resource: resource.attributes }
      end

      it 'returns HTTP status 422' do
        expect(response).to have_http_status 422
      end

      it 'returns empty data' do
        body = JSON.parse(response.body)

        expect(body['errors']).to eq("document"=>["can't be blank"], 'name' => ['can\'t be blank'])
      end
    end
  end
end
