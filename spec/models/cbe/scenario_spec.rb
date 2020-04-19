# == Schema Information
#
# Table name: cbe_scenarios
#
#  id             :bigint           not null, primary key
#  content        :string
#  created_at     :datetime         not null
#  updated_at     :datetime         not null
#  cbe_section_id :bigint
#  name           :string
#  destroyed_at   :datetime
#  active         :boolean          default("true")
#
require 'rails_helper'
require 'concerns/cbe_support_spec.rb'

RSpec.describe Cbe::Scenario, type: :model do
  let(:cbe_scenario) { build(:cbe_scenario, :with_section) }

  describe 'Should Respond' do
    it { should respond_to(:name) }
    it { should respond_to(:content) }
    it { should respond_to(:cbe_section_id) }
    it { should respond_to(:active) }
    it { should respond_to(:destroyed_at) }
    it { should respond_to(:created_at) }
    it { should respond_to(:updated_at) }
  end

  describe 'Associations' do
    it { should belong_to(:section) }
  end

  describe 'Validations' do
    it { should validate_presence_of(:content) }
    it { should validate_presence_of(:cbe_section_id) }
  end

  describe 'Concern' do
    it_behaves_like 'cbe_support'
  end

  describe 'Factory' do
    it { expect(cbe_scenario).to be_a Cbe::Scenario }
    it { expect(cbe_scenario).to be_valid }
  end
end
