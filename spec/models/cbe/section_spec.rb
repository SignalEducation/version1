require 'rails_helper'

RSpec.describe Cbe::Section, type: :model do
  let(:cbe_section) { build(:cbe_section, :with_cbe) }

  describe 'Should Respond' do
    it { should respond_to(:name) }
    it { should respond_to(:scenario_description) }
    it { should respond_to(:question_description) }
    it { should respond_to(:scenario_label) }
    it { should respond_to(:question_label) }
    it { should respond_to(:cbe_id) }
    it { should respond_to(:created_at) }
    it { should respond_to(:updated_at) }
  end

  describe 'Associations' do
    it { should belong_to(:cbe) }
  end

  describe 'Validations' do
    it { should validate_presence_of(:name) }
    it { should validate_presence_of(:scenario_label) }
    it { should validate_presence_of(:scenario_description) }
    it { should validate_presence_of(:cbe_id) }
  end

  describe 'Factory' do
    it { expect(cbe_section).to be_a Cbe::Section }
    it { expect(cbe_section).to be_valid }
  end
end
