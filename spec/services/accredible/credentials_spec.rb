# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Accredible::Credentials, type: :service do
  let(:user)         { build(:user) }
  let(:key)          { Rails.application.credentials[Rails.env.to_sym][:accredible][:api_key] }
  let(:uri)          { Rails.application.credentials[Rails.env.to_sym][:accredible][:api_url] }
  let(:credentials)  { described_class.new }

  describe '#create' do
    context 'Correct request' do
      it 'create a new credential in accredible api' do
        stub_request(:post, "https://#{uri}/v1/credentials").
          with(body: "{\"credential\":{\"recipient\":{\"name\":\"#{user.name}\",\"email\":\"#{user.email}\"},\"group_id\":23}}",
               headers: { 'Accept' => '*/*', 'Accept-Encoding' => 'gzip;q=1.0,deflate;q=0.6,identity;q=0.3', 'Authorization' => "Token token=#{key}", 'Content-Type' => 'application/json', 'User-Agent' => 'Ruby' }).
          to_return(status: 200, body: { "credential": { "recipient": { "name": user.name, "email": user.email,"id": 817 } } }.to_json, headers: {})

        response = credentials.create(user.name, user.email, 23)

        expect(response[:status]).to eq('200')
      end
    end

    context 'Incorrect request' do
      it 'not create a new credential in accredible api' do
        stub_request(:post, "https://#{uri}/v1/credentials").
          with(body: "{\"credential\":{\"recipient\":{\"name\":\"#{user.name}\",\"email\":\"#{user.email}\"},\"group_id\":23}}",
               headers: { 'Accept' => '*/*', 'Accept-Encoding' => 'gzip;q=1.0,deflate;q=0.6,identity;q=0.3', 'Authorization' => "Token token=#{key}", 'Content-Type' => 'application/json', 'User-Agent' => 'Ruby' }).
          to_return(status: 302, body: { "credential": { "recipient": { "name": user.name, "email": user.email,"id": 817 } } }.to_json, headers: {})

        response = credentials.create(user.name, user.email, 23)

        expect(response[:status]).to eq('302')
      end
    end
  end

  describe '#details' do
    it 'return' do
      stub_request(:get, "https://#{uri}/v1/credentials/#{23}").
        with(headers: { 'Accept' => '*/*', 'Accept-Encoding' => 'gzip;q=1.0,deflate;q=0.6,identity;q=0.3', 'Authorization' => "Token token=#{key}", 'Content-Type' => 'application/json', 'User-Agent' => 'Ruby' }).
        to_return(status: 200, body: '{}', headers: {})

      response = credentials.details(23)

      expect(response[:status]).to eq('200')
    end
  end

  describe '#by_group' do
    it 'not create a new credential in accredible api' do
      stub_request(:post, "https://#{uri}/v1/credentials/search").
        with(body: "{\"group_id\":23}",
             headers: { 'Accept' => '*/*', 'Accept-Encoding' => 'gzip;q=1.0,deflate;q=0.6,identity;q=0.3', 'Authorization' => "Token token=#{key}", 'Content-Type' => 'application/json', 'User-Agent' => 'Ruby' }).
        to_return(status: 200, body: '{}', headers: {})

      response = credentials.by_group(23)

      expect(response[:status]).to eq('200')
    end
  end
end
