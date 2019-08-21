require 'rails_helper'

RSpec.describe Cbe::Question, type: :model do
  let(:cbe_question) { build(:cbe_question, :with_section) }

  describe 'Should Respond' do
    it { should respond_to(:label) }
    it { should respond_to(:description) }
    it { should respond_to(:kind) }
    it { should respond_to(:cbe_section_id) }
    it { should respond_to(:created_at) }
    it { should respond_to(:updated_at) }
  end

  describe 'Factory' do
    it { expect(cbe_question).to be_a Cbe::Question }
    it { expect(cbe_question).to be_valid }
  end
end
