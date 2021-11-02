# frozen_string_literal: true

# == Schema Information
#
# Table name: practice_question_solutions
#
#  id                   :bigint           not null, primary key
#  name                 :string
#  practice_question_id :integer
#  sorting_order        :integer
#  kind                 :integer
#  content              :json
#  created_at           :datetime         not null
#  updated_at           :datetime         not null
#
require 'rails_helper'

RSpec.describe PracticeQuestion::Solution, type: :model do
  describe 'Should Respond' do
    it { should respond_to(:practice_question_id) }
    it { should respond_to(:sorting_order) }
    it { should respond_to(:kind) }
    it { should respond_to(:content) }
    it { should respond_to(:created_at) }
    it { should respond_to(:updated_at) }
  end

  describe 'Associations' do
    it { should belong_to(:practice_question) }
  end

  describe 'Validations' do
    it { should validate_presence_of(:name) }
    it { should validate_presence_of(:practice_question_id) }

    before { allow(subject).to receive(:spreadsheet?).and_return(true) }
    it { should validate_presence_of(:content) }
  end

  describe 'Enums' do
    it { should define_enum_for(:kind).with(open: 0, spreadsheet: 1) }
  end

  describe 'scopes' do
    it { expect(described_class).to respond_to(:all_in_order) }
  end

  it '.destroyable?' do
    expect(described_class.new.destroyable?).to be_truthy
  end
end
