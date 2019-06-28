require 'rails_helper'

RSpec.describe Cbe, type: :model do

  context "When testing the CBE Model" do
    it 'validates presence' do
      cbe = Cbe.new
      expect(cbe.name).to eq nil
    end
  end
end
