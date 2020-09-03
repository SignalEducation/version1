# frozen_string_literal: true

require 'rails_helper'

RSpec.describe HubSpot::FormContacts do
  let(:user_01)       { build(:user) }
  let(:user_02)       { build(:user) }
  let(:key)           { Rails.application.credentials[Rails.env.to_sym][:hubspot][:form_api][:portal_id] }
  let(:uri)           { 'https://api.hsforms.com' }
  let(:form_contacts) { described_class.new }

  describe '#create' do
    subject do
      allow(User).to receive(:find).and_return(user_01)
    end

    context 'Correct request' do
      it 'save parsed data in hubspot' do
        data = { first_name: user_01.first_name, last_name: user_01.last_name, email: user_01.email, hutk: user_01.hutk, hs_form_id: user_01.hs_form_id, consent: user_01.terms_and_conditions }
        stub_request(:post, "#{uri}/submissions/v3/integration/submit/#{key}/#{user_01.hs_form_id}/").
          with(body: "{\"fields\":[{\"name\":\"email\",\"value\":\"#{user_01.email}\"},{\"name\":\"firstname\",\"value\":\"#{user_01.first_name}\"},{\"name\":\"lastname\",\"value\":\"#{user_01.last_name}\"}],\"context\":{\"hutk\":null},\"legalConsentOptions\":{\"consent\":{\"consentToProcess\":true,\"text\":\"I agree to learnsignal's terms and conditions\"}}}").
          to_return(status: 200, body: 'OK', headers: {})

        response = form_contacts.create(data)

        expect(response.code).to eq('200')
        expect(response.body).to eq('OK')
      end
    end

    context 'Incorrect request' do
      it 'no save parsed data in hubspot' do
        data = { first_name: user_01.first_name, last_name: user_01.last_name, email: user_01.email, hutk: user_01.hutk, hs_form_id: user_01.hs_form_id, consent: user_01.terms_and_conditions }
        stub_request(:post, "#{uri}/submissions/v3/integration/submit/#{key}/#{user_01.hs_form_id}/").
          with(body: "{\"fields\":[{\"name\":\"email\",\"value\":\"#{user_01.email}\"},{\"name\":\"firstname\",\"value\":\"#{user_01.first_name}\"},{\"name\":\"lastname\",\"value\":\"#{user_01.last_name}\"}],\"context\":{\"hutk\":null},\"legalConsentOptions\":{\"consent\":{\"consentToProcess\":true,\"text\":\"I agree to learnsignal's terms and conditions\"}}}").
          to_return(status: 200, body: '', headers: {})

        response = form_contacts.create(data)

        expect(response).to be_truthy
      end
    end
  end
end
