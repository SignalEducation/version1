# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Zendesk::Requests do
  let(:name)    { Faker::Name.name }
  let(:email)   { Faker::Internet.email }
  let(:matter)  { Faker::Lorem.sentence }
  let(:message) { Faker::Lorem.paragraph  }

  describe '#create' do
    subject do
      stub_request(:post, 'https://learnsignal.zendesk.com/api/v2/requests').
        with(body: "{\"request\":{\"subject\":\"#{matter}\",\"comment\":{\"body\":\"#{message}\"},\"requester\":{\"name\":\"#{name}\",\"email\":\"#{email}\"},\"custom_fields\":[{\"id\":360005584497,\"value\":\"#{name}\"},{\"id\":360005553538,\"value\":\"#{email}\"}]}}").
        to_return(status: 200, body: '', headers: {})
    end

    context 'Correct request' do
      it 'save parsed data in hubspot' do
        subject
        response = Zendesk::Requests.new(name, email, matter, message).create

        expect(response[:subject]).to eq(matter)
        expect(response[:comment][:body]).to eq(message)
        expect(response[:requester][:name]).to eq(name)
        expect(response[:requester][:email]).to eq(email)
      end
    end
  end
end
