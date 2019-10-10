# frozen_string_literal: true

require 'rails_helper'

RSpec.describe HubSpot::Contacts do
  let(:user_01)      { build(:user) }
  let(:user_02)      { build(:user) }
  let(:exam_body)    { build(:exam_body, active: true, name: 'EXAM_BODY_NAME') }
  let(:plan)         { build(:subscription_plan, exam_body: exam_body) }
  let(:subscription) { build(:subscription, state: :active, user: user_01, subscription_plan: plan) }
  let(:key)          { Rails.application.credentials[Rails.env.to_sym][:hubspot][:api_key] }
  let(:uri)          { 'http://api.hubapi.com' }
  let(:contacts)     { described_class.new }

  describe '#create' do
    subject do
      allow(User).to receive(:find).and_return(user_01)
      allow_any_instance_of(User).to receive(:viewable_subscriptions).and_return([subscription])
    end

    it 'save parsed data in hubspot' do
      subject

      stub_request(:post, "#{uri}/contacts/v1/contact?hapikey=#{key}").
        with(body: "{\"properties\":[{\"property\":\"email\",\"value\":\"#{user_01.email}\"},{\"property\":\"firstname\",\"value\":\"#{user_01.first_name}\"},{\"property\":\"lastname\",\"value\":\"#{user_01.last_name}\"},{\"property\":\"email_verified\",\"value\":false},{\"property\":\"date_of_birth\",\"value\":\"#{user_01.date_of_birth}\"},{\"property\":\"currency\",\"value\":\"#{user_01.currency.name}\"},{\"property\":\"country\",\"value\":\"#{user_01&.country&.name}\"},{\"property\":\"preferred_exam_body\",\"value\":\"#{user_01&.preferred_exam_body&.name}\"},{\"property\":\"#{user_01&.preferred_exam_body&.name&.downcase}_status\",\"value\":\"Basic\"}]}").
        to_return(status: 200, body: 'OK', headers: {})

      response = contacts.create(user_01)

      expect(response.code).to eq('200')
      expect(response.body).to eq('OK')
    end
  end

  describe '#batch_create' do
    let(:users) { [user_01, user_02] }

    subject do
      allow(User).to receive(:find).and_return(users)
    end

    it 'save parsed data in hubspot' do
      subject

      stub_request(:post, "#{uri}/contacts/v1/contact/batch/?hapikey=#{key}").
        with(body: '[]').
        to_return(status: 202, body: '', headers: {})

      response = contacts.batch_create(users)

      expect(response.body).to    eq('')
      expect(response.code).to    eq('202')
    end

    it 'save parsed data with custom data in hubspot' do
      subject

      stub_request(:post, "#{uri}/contacts/v1/contact/batch/?hapikey=#{key}").
        with(body: '[]').
        to_return(status: 202, body: '', headers: {})

      response = contacts.batch_create(users, custom_data: 'any_data_here')

      expect(response.body).to    eq('')
      expect(response.code).to    eq('202')
    end
  end
end
