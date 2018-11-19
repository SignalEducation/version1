require 'rails_helper'

describe PaypalService, type: :service do

  # PRIVATE METHODS ############################################################

  describe '#learnsignal_host' do
    describe 'non-production ENVs' do
      it 'returns the correct host' do
        expect(subject.send(:learnsignal_host))
          .to eq 'https://staging.learnsignal.com'
      end
    end

    describe 'production ENV' do
      before :each do
        Rails.env.stub(:production? => true)
      end

      it 'returns the correct host' do
        expect(subject.send(:learnsignal_host)).to eq 'https://learnsignal.com'
      end
    end
  end
end