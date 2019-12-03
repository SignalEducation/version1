# frozen_string_literal: true

require 'rails_helper'
require 'rack/test'

RSpec.describe 'Api::V1::Cbe::IntroductionPagesController', type: :request do
  let(:cbe) { create(:cbe) }

  describe 'get /api/v1/cbes/:cbe_id/introduction_pages' do
    context 'return all records' do
      let!(:introduction_pages) { create_list(:cbe_introduction_page, 5, cbe: cbe) }

      before { get "/api/v1/cbes/#{cbe.id}/introduction_pages" }

      it 'returns HTTP status 200' do
        expect(response).to have_http_status 200
      end

      it 'returns indtroduction pages json data' do
        body = JSON.parse(response.body)

        expect(body.size).to eq(5)
        expect(body.map { |j| j['id'] }).to match_array(introduction_pages.pluck(:id))
        expect(body.map { |j| j['title'] }).to match_array(introduction_pages.pluck(:title))
        expect(body.map { |j| j['content'] }).to match_array(introduction_pages.pluck(:content))
        expect(body.map { |j| j['kind'] }).to match_array(introduction_pages.pluck(:kind))
        expect(body.map { |j| j['sorting_order'] }).to match_array(introduction_pages.pluck(:sorting_order))
      end
    end

    context 'return an empty record' do
      before { get "/api/v1/cbes/#{cbe.id}/introduction_pages" }

      it 'returns HTTP status 200' do
        expect(response).to have_http_status 200
      end

      it 'returns empty data' do
        body = JSON.parse(response.body)
        expect(body).to be_empty
      end
    end
  end

  describe 'post /api/v1/cbe/:cbe_id/introduction_pages/:id' do
    context 'update a valid CBE introduction_pages' do
      let(:introduction_page) { create(:cbe_introduction_page, cbe: cbe) }

      before do
        patch "/api/v1/cbes/#{cbe.id}/introduction_pages/#{introduction_page.id}", params: { cbe_introduction_page: { title: 'New title' } }
      end

      it 'returns HTTP status 200' do
        expect(response).to have_http_status 200
      end

      it 'returns introduction page json data' do
        body = JSON.parse(response.body)

        expect(body['title']).to eq('New title')
      end
    end

    context 'try to update an invalid CBE introduction page' do
      let(:introduction_page) { create(:cbe_introduction_page, cbe: cbe) }

      before do
        introduction_page.title = nil
        patch "/api/v1/cbes/#{cbe.id}/introduction_pages/#{introduction_page.id}", params: { cbe_introduction_page: introduction_page.attributes }
      end

      it 'returns HTTP status 422' do
        expect(response).to have_http_status 422
      end

      it 'returns empty data' do
        body = JSON.parse(response.body)
        expect(body['errors']).to eq('title' => ['can\'t be blank'])
      end
    end
  end

  describe 'patch /api/v1/cbe/introduction_pages' do
    context 'create a valid CBE introduction page' do
      let(:introduction_page) { build(:cbe_introduction_page, cbe: cbe) }

      before do
        post "/api/v1/cbes/#{cbe.id}/introduction_pages", params: { cbe_introduction_page: introduction_page.attributes }
      end

      it 'returns HTTP status 200' do
        expect(response).to have_http_status 200
      end

      it 'returns introduction_page json data' do
        body = JSON.parse(response.body)

        expect(body['title']).to eq(introduction_page.title)
      end
    end

    context 'try to create a invalid CBE introduction page' do
      let(:introduction_page) { build(:cbe_introduction_page, cbe: cbe) }

      before do
        introduction_page.title = nil
        post "/api/v1/cbes/#{cbe.id}/introduction_pages", params: { cbe_introduction_page: introduction_page.attributes }
      end

      it 'returns HTTP status 422' do
        expect(response).to have_http_status 422
      end

      it 'returns empty data' do
        body = JSON.parse(response.body)

        expect(body['errors']).to eq('title' => ["can't be blank"])
      end
    end
  end

  describe 'post /api/v1/cbe/:cbe_id/introduction_pages/:id' do
    context 'destroy a valid CBE introduction_pages' do
      let(:introduction_page) { create(:cbe_introduction_page, cbe: cbe) }

      before do
        delete "/api/v1/cbes/#{cbe.id}/introduction_pages/#{introduction_page.id}"
      end

      it 'returns HTTP status 202' do
        body = JSON.parse(response.body)

        expect(response).to have_http_status 202
        expect(body['message']).to eq("Page #{introduction_page.id} was deleted.")
      end
    end
  end
end
