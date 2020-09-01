# frozen_string_literal: true

# == Schema Information
#
# Table name: cbe_exhibits
#
#  id                    :bigint           not null, primary key
#  name                  :string
#  kind                  :integer
#  content               :json
#  sorting_order         :integer
#  document_file_name    :string
#  document_content_type :string
#  document_file_size    :bigint
#  document_updated_at   :datetime
#  created_at            :datetime         not null
#  updated_at            :datetime         not null
#  cbe_scenario_id       :bigint
#
require 'rails_helper'
require 'concerns/cbe_support_spec.rb'

RSpec.describe Cbe::Exhibit, type: :model do
  let(:cbe_exhibit) { build(:cbe_exhibits, :with_pdf, :with_scenario) }

  describe 'Should Respond' do
    it { should respond_to(:name) }
    it { should respond_to(:kind) }
    it { should respond_to(:content) }
    it { should respond_to(:sorting_order) }
    it { should respond_to(:document_file_name) }
    it { should respond_to(:document_content_type) }
    it { should respond_to(:document_updated_at) }
    it { should respond_to(:cbe_scenario_id) }
    it { should respond_to(:created_at) }
    it { should respond_to(:updated_at) }
  end

  describe 'Associations' do
    it { should belong_to(:scenario) }
  end

  describe 'Validations' do
    it { should validate_presence_of(:name) }
    it { should validate_presence_of(:kind) }
    it { should validate_presence_of(:sorting_order) }
    it { should validate_presence_of(:cbe_scenario_id) }
    it { should validate_numericality_of(:sorting_order).is_greater_than_or_equal_to(0) }

    before { allow(subject).to receive(:spreadsheet?).and_return(true) }
    it { should validate_presence_of(:content) }

    before { allow(subject).to receive(:pdf?).and_return(true) }
    it { should validate_attachment_presence(:document) }
  end

  describe 'Enums' do
    it { should define_enum_for(:kind).with(pdf: 0, spreadsheet: 1) }
  end

  describe 'scopes' do
    it { expect(Cbe::Exhibit).to respond_to(:by_scenario) }
  end

  describe 'Factory' do
    it { expect(cbe_exhibit).to be_a Cbe::Exhibit }
    it { expect(cbe_exhibit).to be_valid }
  end
end
