require 'rails_helper'

RSpec.describe Cbe::UserAnswer, type: :model do
  let(:cbe_user_answer) { build(:cbe_user_answer, :with_question) }

  describe 'Should Respond' do
    it { should respond_to(:content) }
    it { should respond_to(:cbe_user_log_id) }
    it { should respond_to(:cbe_question_id) }
    it { should respond_to(:cbe_answer_id) }
    it { should respond_to(:created_at) }
    it { should respond_to(:updated_at) }
  end

  describe 'Associations' do
    it { should belong_to(:user_log) }
    it { should belong_to(:question) }
  end

  describe 'Validations' do
    it { should validate_presence_of(:content) }
  end

  describe 'Factory' do
    it { expect(cbe_user_answer).to be_a Cbe::UserAnswer }
    it { expect(cbe_user_answer).to be_valid }
  end
end
