# frozen_string_literal: true

# == Schema Information
#
# Table name: cbe_response_options
#
#  id              :bigint           not null, primary key
#  kind            :integer
#  quantity        :integer
#  sorting_order   :integer
#  created_at      :datetime         not null
#  updated_at      :datetime         not null
#  cbe_scenario_id :bigint
#
require 'rails_helper'

RSpec.describe Cbe::ResponseOption, type: :model do
  let(:cbe_response_option) { build(:cbe_response_options) }

  describe 'Should Respond' do
    it { should respond_to(:kind) }
    it { should respond_to(:quantity) }
    it { should respond_to(:sorting_order) }
    it { should respond_to(:cbe_scenario_id) }
    it { should respond_to(:created_at) }
    it { should respond_to(:updated_at) }
  end

  describe 'Associations' do
    it { should belong_to(:scenario) }
    it do
      should have_many(:user_responses).
               class_name('Cbe::UserResponse').
               with_foreign_key('cbe_response_option_id')
    end
  end

  describe 'scopes' do
    it { expect(Cbe::ResponseOption).to respond_to(:without_scenario) }
    it { expect(Cbe::ResponseOption).to respond_to(:with_scenario) }
    it { expect(Cbe::ResponseOption).to respond_to(:by_section) }
  end

  describe 'Validations' do
    it { should validate_presence_of(:kind) }
    it { should validate_presence_of(:sorting_order) }

    context 'is a multiple_open' do
      before { allow(subject).to receive(:multiple_open?).and_return(true) }

      it { should validate_presence_of(:quantity) }
      it { should validate_numericality_of(:quantity).is_greater_than_or_equal_to(0) }
    end
  end

  describe 'Enums' do
    it { should define_enum_for(:kind).with(open: 0, multiple_open: 1, spreadsheet: 2) }
  end

  describe 'Factory' do
    it { expect(cbe_response_option).to be_a Cbe::ResponseOption }
    it { expect(cbe_response_option).to be_valid }
  end

  describe 'Methods' do
    let(:open_response)          { build(:cbe_response_options, kind: :open) }
    let(:spreadsheet_response)   { build(:cbe_response_options, kind: :spreadsheet) }
    let(:multiple_open_response) { build(:cbe_response_options, kind: :multiple_open) }

    context '.formatted_kind' do
      context 'Open' do
        it { expect(open_response.formatted_kind).to eq('Word Processor') }
      end

      context 'Open' do
        it { expect(spreadsheet_response.formatted_kind).to eq('Spreadsheet') }
      end

      context 'Slides' do
        it { expect(multiple_open_response.formatted_kind).to eq('Slides') }
      end
    end
  end
end
