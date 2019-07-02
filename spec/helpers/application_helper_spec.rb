require 'rails_helper'

RSpec.describe ApplicationHelper, type: :helper do
  describe '#humanize_stripe_date_full' do
    context 'with a date passed in' do
      it 'returns the correctly formatted date' do
        expect(humanize_stripe_date_full(Date.new(2018,11,16))).to eq '16 November 2018'
      end
    end

    context 'without a date' do
      it 'returns the correctly formatted date' do
        Timecop.freeze(2018, 11, 16) do
          expect(humanize_stripe_date_full).to eq '16 December 2018'
        end
      end
    end
  end

  describe '#humanize_stripe_date' do
    context 'with a date passed in' do
      it 'returns the correctly formatted date' do
        expect(humanize_stripe_date(Date.new(2018,11,16))).to eq '16 Nov 18'
      end
    end

    context 'without a date' do
      it 'returns the correctly formatted date' do
        Timecop.freeze(2018, 11, 16) do
          expect(humanize_stripe_date).to eq '16 Dec 18'
        end
      end
    end
  end
end
