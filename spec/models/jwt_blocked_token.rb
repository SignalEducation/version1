# frozen_string_literal: true

require 'rails_helper'

RSpec.describe JwtBlockedToken, type: :model do
  before { create(:bearer) }

  let(:bearer) { build(:jwt_blocked_token) }

  describe 'Should Respond' do
    it { should respond_to(:token) }
    it { should respond_to(:created_at) }
    it { should respond_to(:updated_at) }
  end

  describe 'Validations' do
    it { should validate_presence_of(:token) }
  end
end
