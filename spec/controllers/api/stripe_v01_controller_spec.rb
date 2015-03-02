require 'rails_helper'

describe Api::StripeV01Controller, type: :controller do

  describe "POST 'create'" do
    it 'returns 200 when called' do
      post :create
      expect(response.status).to eq(200)
    end

    it 'logs an error if invalid JSON is received' do
      expect(Rails.logger).to receive(:error)
      post :create
      expect(response.status).to eq(200)
    end

    it 'work in progress' do
      StripeMock.start
      event = StripeMock.mock_webhook_event('customer.subscription.updated')

      post :create, event: event

    end
  end

end
