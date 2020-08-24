# frozen_string_literal: true

# == Schema Information
#
# Table name: cbe_requirements
#
#  id              :bigint           not null, primary key
#  name            :string
#  content         :text
#  score           :float
#  sorting_order   :integer
#  kind            :integer
#  created_at      :datetime         not null
#  updated_at      :datetime         not null
#  cbe_scenario_id :bigint
#  solution        :text
#
require 'rails_helper'
require 'concerns/cbe_support_spec.rb'

RSpec.describe Cbe::Requirement, type: :model do
  let(:cbe_requirement) { build(:cbe_requirements, :with_scenario) }

  describe 'Should Respond' do
    it { should respond_to(:name) }
    it { should respond_to(:kind) }
    it { should respond_to(:content) }
    it { should respond_to(:sorting_order) }
    it { should respond_to(:score) }
    it { should respond_to(:solution) }
    it { should respond_to(:cbe_scenario_id) }
    it { should respond_to(:created_at) }
    it { should respond_to(:updated_at) }
  end

  describe 'Associations' do
    it { should belong_to(:scenario) }
  end

  describe 'Validations' do
    it { should validate_presence_of(:name) }
    it { should validate_presence_of(:content) }
    it { should validate_presence_of(:kind) }
    it { should validate_presence_of(:sorting_order) }
    it { should validate_presence_of(:cbe_scenario_id) }
    it { should validate_numericality_of(:sorting_order).is_greater_than_or_equal_to(0) }
  end

  describe 'Enums' do
    it { should define_enum_for(:kind).with(requirement: 0, task: 1) }
  end

  describe 'scopes' do
    it { expect(Cbe::Requirement).to respond_to(:by_scenario) }
  end

  describe 'Factory' do
    it { expect(cbe_requirement).to be_a Cbe::Requirement }
    it { expect(cbe_requirement).to be_valid }
  end
end
