require 'rails_helper'

describe Api::StripeV01Controller, type: :controller do

  describe 'Controller fundamentals:' do
    it { expect(Api::StripeV01Controller.const_defined?(:ACCEPTED_TYPES)).to eq(true) }
  end

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
  end

end
