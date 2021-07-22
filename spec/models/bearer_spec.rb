# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Bearer, type: :model do
  before { create(:bearer) }

  let(:bearer) { build(:bearer) }

  describe 'Should Respond' do
    it { should respond_to(:name) }
    it { should respond_to(:slug) }
    it { should respond_to(:api_key) }
    it { should respond_to(:status) }
    it { should respond_to(:created_at) }
    it { should respond_to(:updated_at) }
  end

  describe 'Validations' do
    it { should validate_presence_of(:name) }
    it { should validate_presence_of(:slug) }
    it { should validate_presence_of(:status) }
    it { should validate_uniqueness_of(:name) }
    it { should validate_uniqueness_of(:slug) }
    it { should validate_uniqueness_of(:api_key) }
    it { should allow_value(bearer.slug).for(:slug) }
  end

  describe 'Enums' do
    it { should define_enum_for(:status).with(inactive: 0, active: 1) }
  end

  describe 'return a default inactive status' do
    it { expect(bearer.inactive?).to be_truthy }
  end

  describe '#generate_api_key' do
    context 'return a api_key after build' do
      it { expect(bearer.api_key).to_not be_nil }
    end
  end
end
