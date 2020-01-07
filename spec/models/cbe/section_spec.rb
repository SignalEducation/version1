require 'rails_helper'

RSpec.describe Cbe::Section, type: :model do
  let(:cbe_section) { create(:cbe_section, :with_cbe) }

  describe 'Should Respond' do
    it { should respond_to(:name) }
    it { should respond_to(:score) }
    it { should respond_to(:kind) }
    it { should respond_to(:sorting_order) }
    it { should respond_to(:content) }
    it { should respond_to(:cbe_id) }
    it { should respond_to(:created_at) }
    it { should respond_to(:updated_at) }
  end

  describe 'Associations' do
    it { should belong_to(:cbe) }
    it { should have_many(:questions) }
    it { should have_many(:scenarios) }
  end

  describe 'Validations' do
    it { should validate_presence_of(:name) }
    it { should validate_presence_of(:kind) }
    it { should validate_presence_of(:cbe_id) }
  end

  describe 'Enums' do
    it do
      should define_enum_for(:kind).
               with(objective: 0, constructed_response: 1, objective_test_case: 2)
    end
  end

  describe 'Factory' do
    it { expect(cbe_section).to be_a Cbe::Section }
    it { expect(cbe_section).to be_valid }
  end
end
