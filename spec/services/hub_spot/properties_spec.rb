# frozen_string_literal: true

require 'rails_helper'

RSpec.describe HubSpot::Properties do
  let(:key)              { Rails.application.credentials[Rails.env.to_sym][:hubspot][:main_api][:api_key] }
  let(:uri)              { 'https://api.hubapi.com' }
  let(:properties)       { described_class.new }
  let(:exam_body_status) { 'acca_status' }

  describe '#exists?' do
    context 'find request' do
      it 'search for acca status' do
        stub_request(:get, "#{uri}/properties/v1/contacts/properties/named/#{exam_body_status}?hapikey=#{key}").
          with(headers: { 'Accept'=>'*/*', 'Accept-Encoding'=>'gzip;q=1.0,deflate;q=0.6,identity;q=0.3', 'Content-Type'=>'application/json', 'User-Agent'=>'Ruby' } ).
          to_return(status: 200, body: 'OK', headers: {})

        response = properties.exists?(exam_body_status)

        expect(response).to be_truthy
      end
    end

    context 'not find request' do
      it 'search for acca status' do
        stub_request(:get, "#{uri}/properties/v1/contacts/properties/named/#{exam_body_status}?hapikey=#{key}").
          with(headers: { 'Accept'=>'*/*', 'Accept-Encoding'=>'gzip;q=1.0,deflate;q=0.6,identity;q=0.3', 'Content-Type'=>'application/json', 'User-Agent'=>'Ruby' } ).
          to_return(status: 404, body: '', headers: {})

        response = properties.exists?(exam_body_status)

        expect(response).to be_falsey
      end
    end
  end
end
