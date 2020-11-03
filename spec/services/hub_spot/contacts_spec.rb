# frozen_string_literal: true

require 'rails_helper'

RSpec.describe HubSpot::Contacts do
  let(:user_01)      { build(:user) }
  let(:user_02)      { build(:user) }
  let(:exam_body)    { build(:exam_body, active: true, name: 'EXAM_BODY_NAME') }
  let(:plan)         { build(:subscription_plan, exam_body: exam_body) }
  let(:subscription) { build(:subscription, state: :active, user: user_01, subscription_plan: plan) }
  let(:key)          { Rails.application.credentials[Rails.env.to_sym][:hubspot][:main_api][:api_key] }
  let(:uri)          { 'https://api.hubapi.com' }
  let(:contacts)     { described_class.new }

  describe '#create' do
    subject do
      allow(User).to receive(:find).and_return(user_01)
      allow_any_instance_of(User).to receive(:viewable_subscriptions).and_return([subscription])
    end

    context 'Correct request' do
      it 'save parsed data in hubspot' do
        subject
        preferred_exam_body = user_01.preferred_exam_body.hubspot_property.parameterize(separator: '_')

        stub_request(:post, "#{uri}/contacts/v1/contact?hapikey=#{key}").
          with(body: "{\"properties\":[{\"property\":\"email\",\"value\":\"#{user_01.email}\"},{\"property\":\"firstname\",\"value\":\"#{user_01.first_name}\"},{\"property\":\"lastname\",\"value\":\"#{user_01.last_name}\"},{\"property\":\"email_verified\",\"value\":false},{\"property\":\"ls_created_at\",\"value\":null},{\"property\":\"date_of_birth\",\"value\":\"#{user_01.date_of_birth}\"},{\"property\":\"currency\",\"value\":\"#{user_01.currency.name}\"},{\"property\":\"country\",\"value\":\"#{user_01&.country&.name}\"},{\"property\":\"user_group\",\"value\":\"#{user_01&.user_group&.name}\"},{\"property\":\"sub_close_date_2\",\"value\":null},{\"property\":\"sub_payment_interval\",\"value\":null},{\"property\":\"sub_exam_body\",\"value\":null},{\"property\":\"sub_type\",\"value\":null},{\"property\":\"sub_canceled_at\",\"value\":null},{\"property\":\"sub_cancelation_reason\",\"value\":null},{\"property\":\"sub_cancelation_note\",\"value\":null},{\"property\":\"sub_renewal_date\",\"value\":null},{\"property\":\"last_purchased_course\",\"value\":null},{\"property\":\"preferred_exam_body\",\"value\":\"#{user_01&.preferred_exam_body&.name}\"},{\"property\":\"#{preferred_exam_body}\",\"value\":\"Basic\"}]}").
          to_return(status: 200, body: 'OK', headers: {})

        response = contacts.create(user_01)

        expect(response.code).to eq('200')
        expect(response.body).to eq('OK')
      end
    end

    context 'Incorrect request' do
      it 'no save parsed data in hubspot' do
        subject
        preferred_exam_body = user_01.preferred_exam_body.hubspot_property.parameterize(separator: '_')

        stub_request(:post, "#{uri}/contacts/v1/contact?hapikey=#{key}").
            with(body: "{\"properties\":[{\"property\":\"email\",\"value\":\"#{user_01.email}\"},{\"property\":\"firstname\",\"value\":\"#{user_01.first_name}\"},{\"property\":\"lastname\",\"value\":\"#{user_01.last_name}\"},{\"property\":\"email_verified\",\"value\":false},{\"property\":\"ls_created_at\",\"value\":null},{\"property\":\"date_of_birth\",\"value\":\"#{user_01.date_of_birth}\"},{\"property\":\"currency\",\"value\":\"#{user_01.currency.name}\"},{\"property\":\"country\",\"value\":\"#{user_01&.country&.name}\"},{\"property\":\"user_group\",\"value\":\"#{user_01&.user_group&.name}\"},{\"property\":\"sub_close_date_2\",\"value\":null},{\"property\":\"sub_payment_interval\",\"value\":null},{\"property\":\"sub_exam_body\",\"value\":null},{\"property\":\"sub_type\",\"value\":null},{\"property\":\"sub_canceled_at\",\"value\":null},{\"property\":\"sub_cancelation_reason\",\"value\":null},{\"property\":\"sub_cancelation_note\",\"value\":null},{\"property\":\"sub_renewal_date\",\"value\":null},{\"property\":\"last_purchased_course\",\"value\":null},{\"property\":\"preferred_exam_body\",\"value\":\"#{user_01&.preferred_exam_body&.name}\"},{\"property\":\"#{preferred_exam_body}\",\"value\":\"Basic\"}]}").
          to_return(status: 404, body: 'OK', headers: {})

        response = contacts.create(user_01)

        expect(response).to be_truthy
      end
    end
  end

  describe '#batch_create' do
    let(:users) { [user_01, user_02] }

    subject do
      allow(User).to receive(:where).and_return(users)
    end

    context 'Correct request' do
      it 'save parsed data in hubspot' do
        subject

        preferred_exam_body1 = user_01.preferred_exam_body.hubspot_property.parameterize(separator: '_')
        preferred_exam_body2 = user_02.preferred_exam_body.hubspot_property.parameterize(separator: '_')

        stub_request(:post, "#{uri}/contacts/v1/contact/batch/?hapikey=#{key}").
          with(
            body: "[{\"email\":\"#{user_01.email}\",\"properties\":[{\"property\":\"email\",\"value\":\"#{user_01.email}\"},{\"property\":\"firstname\",\"value\":\"#{user_01.first_name}\"},{\"property\":\"lastname\",\"value\":\"#{user_01.last_name}\"},{\"property\":\"email_verified\",\"value\":false},{\"property\":\"ls_created_at\",\"value\":null},{\"property\":\"date_of_birth\",\"value\":\"#{user_01.date_of_birth}\"},{\"property\":\"currency\",\"value\":\"#{user_01.currency.name}\"},{\"property\":\"country\",\"value\":\"#{user_01&.country&.name}\"},{\"property\":\"user_group\",\"value\":\"#{user_01&.user_group&.name}\"},{\"property\":\"sub_close_date_2\",\"value\":null},{\"property\":\"sub_payment_interval\",\"value\":null},{\"property\":\"sub_exam_body\",\"value\":null},{\"property\":\"sub_type\",\"value\":null},{\"property\":\"sub_canceled_at\",\"value\":null},{\"property\":\"sub_cancelation_reason\",\"value\":null},{\"property\":\"sub_cancelation_note\",\"value\":null},{\"property\":\"sub_renewal_date\",\"value\":null},{\"property\":\"last_purchased_course\",\"value\":null},{\"property\":\"preferred_exam_body\",\"value\":\"#{user_01&.preferred_exam_body&.name}\"},{\"property\":\"#{preferred_exam_body1}\",\"value\":\"Basic\"},{\"property\":\"#{preferred_exam_body2}\",\"value\":\"Basic\"}]},{\"email\":\"#{user_02&.email}\",\"properties\":[{\"property\":\"email\",\"value\":\"#{user_02&.email}\"},{\"property\":\"firstname\",\"value\":\"#{user_02&.first_name}\"},{\"property\":\"lastname\",\"value\":\"#{user_02&.last_name}\"},{\"property\":\"email_verified\",\"value\":false},{\"property\":\"ls_created_at\",\"value\":null},{\"property\":\"date_of_birth\",\"value\":\"#{user_02&.date_of_birth}\"},{\"property\":\"currency\",\"value\":\"#{user_02&.currency&.name}\"},{\"property\":\"country\",\"value\":\"#{user_02&.country&.name}\"},{\"property\":\"user_group\",\"value\":\"#{user_02&.user_group&.name}\"},{\"property\":\"sub_close_date_2\",\"value\":null},{\"property\":\"sub_payment_interval\",\"value\":null},{\"property\":\"sub_exam_body\",\"value\":null},{\"property\":\"sub_type\",\"value\":null},{\"property\":\"sub_canceled_at\",\"value\":null},{\"property\":\"sub_cancelation_reason\",\"value\":null},{\"property\":\"sub_cancelation_note\",\"value\":null},{\"property\":\"sub_renewal_date\",\"value\":null},{\"property\":\"last_purchased_course\",\"value\":null},{\"property\":\"preferred_exam_body\",\"value\":\"#{user_02&.preferred_exam_body&.name}\"},{\"property\":\"#{preferred_exam_body1}\",\"value\":\"Basic\"},{\"property\":\"#{preferred_exam_body2}\",\"value\":\"Basic\"}]}]",
            headers: { 'Accept' => '*/*', 'Accept-Encoding' => 'gzip;q=1.0,deflate;q=0.6,identity;q=0.3', 'Content-Type' => 'application/json', 'User-Agent' => 'Ruby' }
          ).
          to_return(status: 202, body: '', headers: {})

        response = contacts.batch_create(users)

        expect(response.body).to eq('')
        expect(response.code).to eq('202')
      end

      it 'save parsed data with custom data in hubspot' do
        subject

        preferred_exam_body1 = user_01.preferred_exam_body.hubspot_property.parameterize(separator: '_')
        preferred_exam_body2 = user_02.preferred_exam_body.hubspot_property.parameterize(separator: '_')

        stub_request(:post, "#{uri}/contacts/v1/contact/batch/?hapikey=#{key}").
          with(
            body: "[{\"email\":\"#{user_01.email}\",\"properties\":[{\"property\":\"email\",\"value\":\"#{user_01.email}\"},{\"property\":\"firstname\",\"value\":\"#{user_01.first_name}\"},{\"property\":\"lastname\",\"value\":\"#{user_01.last_name}\"},{\"property\":\"email_verified\",\"value\":false},{\"property\":\"ls_created_at\",\"value\":null},{\"property\":\"date_of_birth\",\"value\":\"#{user_01.date_of_birth}\"},{\"property\":\"currency\",\"value\":\"#{user_01.currency.name}\"},{\"property\":\"country\",\"value\":\"#{user_01&.country&.name}\"},{\"property\":\"user_group\",\"value\":\"#{user_01&.user_group&.name}\"},{\"property\":\"sub_close_date_2\",\"value\":null},{\"property\":\"sub_payment_interval\",\"value\":null},{\"property\":\"sub_exam_body\",\"value\":null},{\"property\":\"sub_type\",\"value\":null},{\"property\":\"sub_canceled_at\",\"value\":null},{\"property\":\"sub_cancelation_reason\",\"value\":null},{\"property\":\"sub_cancelation_note\",\"value\":null},{\"property\":\"sub_renewal_date\",\"value\":null},{\"property\":\"last_purchased_course\",\"value\":null},{\"property\":\"preferred_exam_body\",\"value\":\"#{user_01&.preferred_exam_body&.name}\"},{\"property\":\"#{preferred_exam_body1}\",\"value\":\"Basic\"},{\"property\":\"#{preferred_exam_body2}\",\"value\":\"Basic\"},{\"custom_data\":\"any_data_here\"}]},{\"email\":\"#{user_02&.email}\",\"properties\":[{\"property\":\"email\",\"value\":\"#{user_02&.email}\"},{\"property\":\"firstname\",\"value\":\"#{user_02&.first_name}\"},{\"property\":\"lastname\",\"value\":\"#{user_02&.last_name}\"},{\"property\":\"email_verified\",\"value\":false},{\"property\":\"ls_created_at\",\"value\":null},{\"property\":\"date_of_birth\",\"value\":\"#{user_02&.date_of_birth}\"},{\"property\":\"currency\",\"value\":\"#{user_02&.currency&.name}\"},{\"property\":\"country\",\"value\":\"#{user_02&.country&.name}\"},{\"property\":\"user_group\",\"value\":\"#{user_02&.user_group&.name}\"},{\"property\":\"sub_close_date_2\",\"value\":null},{\"property\":\"sub_payment_interval\",\"value\":null},{\"property\":\"sub_exam_body\",\"value\":null},{\"property\":\"sub_type\",\"value\":null},{\"property\":\"sub_canceled_at\",\"value\":null},{\"property\":\"sub_cancelation_reason\",\"value\":null},{\"property\":\"sub_cancelation_note\",\"value\":null},{\"property\":\"sub_renewal_date\",\"value\":null},{\"property\":\"last_purchased_course\",\"value\":null},{\"property\":\"preferred_exam_body\",\"value\":\"#{user_02&.preferred_exam_body&.name}\"},{\"property\":\"#{preferred_exam_body1}\",\"value\":\"Basic\"},{\"property\":\"#{preferred_exam_body2}\",\"value\":\"Basic\"},{\"custom_data\":\"any_data_here\"}]}]",
            headers: { 'Accept' => '*/*', 'Accept-Encoding' => 'gzip;q=1.0,deflate;q=0.6,identity;q=0.3', 'Content-Type' => 'application/json', 'User-Agent' => 'Ruby' }
          ).
          to_return(status: 202, body: '', headers: {})

        response = contacts.batch_create(users, custom_data: 'any_data_here')

        expect(response.body).to eq('')
        expect(response.code).to eq('202')
      end
    end

    context 'Incorrect request' do
      it 'no save parsed data in hubspot' do
        subject

        preferred_exam_body1 = user_01.preferred_exam_body.hubspot_property.parameterize(separator: '_')
        preferred_exam_body2 = user_02.preferred_exam_body.hubspot_property.parameterize(separator: '_')

        stub_request(:post, "#{uri}/contacts/v1/contact/batch/?hapikey=#{key}").
          with(
            body: "[{\"email\":\"#{user_01.email}\",\"properties\":[{\"property\":\"email\",\"value\":\"#{user_01.email}\"},{\"property\":\"firstname\",\"value\":\"#{user_01.first_name}\"},{\"property\":\"lastname\",\"value\":\"#{user_01.last_name}\"},{\"property\":\"email_verified\",\"value\":false},{\"property\":\"ls_created_at\",\"value\":null},{\"property\":\"date_of_birth\",\"value\":\"#{user_01.date_of_birth}\"},{\"property\":\"currency\",\"value\":\"#{user_01.currency.name}\"},{\"property\":\"country\",\"value\":\"#{user_01&.country&.name}\"},{\"property\":\"user_group\",\"value\":\"#{user_01&.user_group&.name}\"},{\"property\":\"sub_close_date_2\",\"value\":null},{\"property\":\"sub_payment_interval\",\"value\":null},{\"property\":\"sub_exam_body\",\"value\":null},{\"property\":\"sub_type\",\"value\":null},{\"property\":\"sub_canceled_at\",\"value\":null},{\"property\":\"sub_cancelation_reason\",\"value\":null},{\"property\":\"sub_cancelation_note\",\"value\":null},{\"property\":\"sub_renewal_date\",\"value\":null},{\"property\":\"last_purchased_course\",\"value\":null},{\"property\":\"preferred_exam_body\",\"value\":\"#{user_01&.preferred_exam_body&.name}\"},{\"property\":\"#{preferred_exam_body1}\",\"value\":\"Basic\"},{\"property\":\"#{preferred_exam_body2}\",\"value\":\"Basic\"}]},{\"email\":\"#{user_02&.email}\",\"properties\":[{\"property\":\"email\",\"value\":\"#{user_02&.email}\"},{\"property\":\"firstname\",\"value\":\"#{user_02&.first_name}\"},{\"property\":\"lastname\",\"value\":\"#{user_02&.last_name}\"},{\"property\":\"email_verified\",\"value\":false},{\"property\":\"ls_created_at\",\"value\":null},{\"property\":\"date_of_birth\",\"value\":\"#{user_02&.date_of_birth}\"},{\"property\":\"currency\",\"value\":\"#{user_02&.currency&.name}\"},{\"property\":\"country\",\"value\":\"#{user_02&.country&.name}\"},{\"property\":\"user_group\",\"value\":\"#{user_02&.user_group&.name}\"},{\"property\":\"sub_close_date_2\",\"value\":null},{\"property\":\"sub_payment_interval\",\"value\":null},{\"property\":\"sub_exam_body\",\"value\":null},{\"property\":\"sub_type\",\"value\":null},{\"property\":\"sub_canceled_at\",\"value\":null},{\"property\":\"sub_cancelation_reason\",\"value\":null},{\"property\":\"sub_cancelation_note\",\"value\":null},{\"property\":\"sub_renewal_date\",\"value\":null},{\"property\":\"last_purchased_course\",\"value\":null},{\"property\":\"preferred_exam_body\",\"value\":\"#{user_02&.preferred_exam_body&.name}\"},{\"property\":\"#{preferred_exam_body1}\",\"value\":\"Basic\"},{\"property\":\"#{preferred_exam_body2}\",\"value\":\"Basic\"}]}]",
            headers: { 'Accept' => '*/*', 'Accept-Encoding' => 'gzip;q=1.0,deflate;q=0.6,identity;q=0.3', 'Content-Type' => 'application/json', 'User-Agent' => 'Ruby' }
          ).
          to_return(status: 404, body: '', headers: {})

        response = contacts.batch_create(users)

        expect(response).to be_truthy
      end
    end
  end

  describe '#search' do
    context 'Correct request' do
      it 'save parsed data in hubspot' do
        stub_request(:get, "#{uri}/contacts/v1/contact/email/#{user_01.email}/profile?hapikey=#{key}").
          with(headers: { 'Accept' => '*/*', 'Accept-Encoding' => 'gzip;q=1.0,deflate;q=0.6,identity;q=0.3', 'Content-Type' => 'application/json', 'User-Agent' => 'Ruby'}).
          to_return(status: 200, body: { body: 'OK', code: 200 }.to_json , headers: {})

        response = contacts.search(user_01.email)

        expect(response['code']).to eq(200)
        expect(response['body']).to eq('OK')
      end
    end
  end
end
