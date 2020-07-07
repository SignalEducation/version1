# frozen_string_literal: true

require 'rails_helper'

describe Numeric, type: :initializer do
  let(:num) { rand(1..99) }

  describe '.percent_of' do
    it { expect(num.percent_of(100)).to eq(num) }
  end
end
