# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Cbe::UserResponse, type: :model do
  let(:cbe_user_response) { build(:cbe_user_response) }

  describe 'Should Respond' do
    it { should respond_to(:content) }
    it { should respond_to(:educator_comment) }
    it { should respond_to(:score) }
    it { should respond_to(:correct) }
    it { should respond_to(:cbe_user_log_id) }
    it { should respond_to(:cbe_response_option_id) }
    it { should respond_to(:created_at) }
    it { should respond_to(:updated_at) }
  end

  describe 'Associations' do
    it { should belong_to(:user_log) }
    it { should belong_to(:cbe_response_option) }
  end

  describe 'scopes' do
    it { expect(Cbe::UserResponse).to respond_to(:by_scenario) }
  end

  describe 'Factory' do
    it { expect(cbe_user_response).to be_a Cbe::UserResponse }
    it { expect(cbe_user_response).to be_valid }
  end
end