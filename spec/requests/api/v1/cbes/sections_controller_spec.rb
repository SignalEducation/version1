# frozen_string_literal: true

require 'rails_helper'

RSpec.describe 'Api::V1::Cbe::SectionsController', type: :request do
  let!(:cbe) { create(:cbe) }

  describe 'get /api/v1/cbe/sections' do
    context 'return all records' do
      let!(:sections) { create_list(:cbe_section, 5, cbe: cbe) }

      before { get "/api/v1/cbes/#{cbe.id}/sections" }

      it 'returns HTTP status 200' do
        expect(response).to have_http_status 200
      end

      it 'returns sections json data' do
        body = JSON.parse(response.body)

        expect(body.size).to eq(5)
        expect(body.map { |j| j['id'] }).to match_array(sections.pluck(:id))
        expect(body.map { |j| j['name'] }).to match_array(sections.pluck(:name))
        expect(body.map(&:keys).uniq).to contain_exactly(%w[id
                                                            name
                                                            score
                                                            kind
                                                            sorting_order
                                                            content
                                                            questions])
      end
    end

    context 'return an empty record' do
      before { get "/api/v1/cbes/#{cbe.id}/sections" }

      it 'returns HTTP status 200' do
        expect(response).to have_http_status 200
      end

      it 'returns empty data' do
        body = JSON.parse(response.body)
        expect(body).to be_empty
      end
    end
  end

  describe 'post /api/v1/cbe/sections' do
    context 'create a valid CBE section' do
      let(:section) { build(:cbe_section, cbe: cbe) }

      before do
        post "/api/v1/cbes/#{cbe.id}/sections", params: { cbe_section: section.attributes }
      end

      it 'returns HTTP status 200' do
        expect(response).to have_http_status 200
      end

      it 'returns sections json data' do
        body = JSON.parse(response.body)

        expect(body['name']).to eq(section.name)
        expect(body['score']).to eq(section.score)
        expect(body['kind']).to eq(section.kind)
        expect(body['sorting_order']).to eq(section.sorting_order)
        expect(body['content']).to eq(section.content)
        expect([body.keys]).to contain_exactly(%w[id
                                                  name
                                                  score
                                                  kind
                                                  sorting_order
                                                  content
                                                  questions])
      end
    end

    context 'try to create a invalid CBE section' do
      let(:section) { build(:cbe_section) }

      before do
        post "/api/v1/cbes/#{cbe.id}/sections", params: { cbe_section: section.attributes }
      end

      it 'returns HTTP status 422' do
        expect(response).to have_http_status 422
      end

      it 'returns empty data' do
        body = JSON.parse(response.body)

        expect(body['errors']).to eq('cbe' => ['must exist'], 'cbe_id' => ['can\'t be blank'])
      end
    end
  end
end
