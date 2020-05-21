# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Accredible::Groups, type: :service do
  let(:key)          { Rails.application.credentials[Rails.env.to_sym][:accredible][:api_key] }
  let(:uri)          { Rails.application.credentials[Rails.env.to_sym][:accredible][:api_url] }
  let(:credentials)  { described_class.new }

  describe '#details' do
    it 'return' do
      stub_request(:get, "https://#{uri}/v1/issuer/groups/#{23}").
        with(headers: { 'Accept' => '*/*', 'Accept-Encoding' => 'gzip;q=1.0,deflate;q=0.6,identity;q=0.3', 'Authorization' => "Token token=#{key}", 'Content-Type' => 'application/json', 'User-Agent' => 'Ruby' }).
        to_return(status: 200, body: '{}', headers: {})

      response = credentials.details(23)

      expect(response[:status]).to eq('200')
    end
  end
end
