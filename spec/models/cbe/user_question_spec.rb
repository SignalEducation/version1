# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Cbe::UserQuestion, type: :model do
  let(:cbe_user_question) { build(:cbe_user_question) }

  describe 'Should Respond' do
    it { should respond_to(:educator_comment) }
    it { should respond_to(:score) }
    it { should respond_to(:correct) }
    it { should respond_to(:cbe_user_log_id) }
    it { should respond_to(:cbe_question_id) }
    it { should respond_to(:created_at) }
    it { should respond_to(:updated_at) }
  end

  describe 'Associations' do
    it { should belong_to(:user_log) }
    it { should belong_to(:cbe_question) }
    it { should have_one(:section) }
    it { should have_many(:answers) }
  end

  describe 'scopes' do
    it { expect(Cbe::UserQuestion).to respond_to(:by_section) }
  end

  describe 'Factory' do
    it { expect(cbe_user_question).to be_a Cbe::UserQuestion }
    it { expect(cbe_user_question).to be_valid }
  end
end