require 'rails_helper'

RSpec.describe ApplicationHelper, type: :helper do
  describe '#tick_or_cross' do
    it 'return a tick span' do
      expect(tick_or_cross(true)).to include('#21CE99')
      expect(tick_or_cross(true)).to include('glyphicon-ok')
    end

    it 'return a cross span' do
      expect(tick_or_cross(false)).to include('#eb4242')
      expect(tick_or_cross(false)).to include('glyphicon-remove')
    end
  end

  describe '#flagged_for_review' do
    it 'return a flagged span' do
      expect(flagged_for_review(true)).to include('#eb4242')
    end

    it 'return a unflagged span' do
      expect(flagged_for_review(false)).to include('#ffffff')
    end
  end

  describe '#number_in_local_currency' do
    let(:currency) { build_stubbed(:currency) }

    it 'return a flagged span' do
      amount = rand(01..99)
      expect(number_in_local_currency(amount, currency)).to eq("#{currency.leading_symbol}#{amount}.00")
    end
  end

  describe '#sanitizer' do
    it 'return a sanitized text' do
      html = '<h2 title="I\'m a header">The title Attribute</h2>'
      expect(sanitizer(html)).to eq('The title Attribute')
    end
  end

  describe '#head_sanitizer' do
    it 'return a sanitized text' do
      html = '<title>Page Title</title>'
      expect(sanitizer(html)).to eq('Page Title')
    end
  end

  describe '#body_sanitizer' do
    it 'return a sanitized text' do
      html = '<p>Note that the form itself is not visible.</p>'
      expect(sanitizer(html)).to eq('<p>Note that the form itself is not visible.</p>')
    end
  end

  describe '#seconds_to_time' do
    seconds_to_time(seconds)
    it 'return a sanitized text' do
      html = '<p>Note that the form itself is not visible.</p>'
      expect(seconds_to_time(300)).to eq('00:05')
    end
  end

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
