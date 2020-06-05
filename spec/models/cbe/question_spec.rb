# == Schema Information
#
# Table name: cbe_questions
#
#  id              :bigint           not null, primary key
#  content         :text
#  created_at      :datetime         not null
#  updated_at      :datetime         not null
#  kind            :integer
#  cbe_section_id  :bigint
#  score           :float
#  sorting_order   :integer
#  cbe_scenario_id :bigint
#  solution        :text
#  destroyed_at    :datetime
#  active          :boolean          default("true")
#
require 'rails_helper'
require 'concerns/cbe_support_spec.rb'

RSpec.describe Cbe::Question, type: :model do
  let(:cbe_question) { build(:cbe_question, :with_section) }

  describe 'Should Respond' do
    it { should respond_to(:content) }
    it { should respond_to(:kind) }
    it { should respond_to(:score) }
    it { should respond_to(:sorting_order) }
    it { should respond_to(:cbe_section_id) }
    it { should respond_to(:cbe_scenario_id) }
    it { should respond_to(:active) }
    it { should respond_to(:destroyed_at) }
    it { should respond_to(:created_at) }
    it { should respond_to(:updated_at) }
  end

  describe 'Associations' do
    it { should belong_to(:section) }
    it { should have_many(:answers) }
  end

  describe 'Validations' do
    it { should validate_presence_of(:content) }
    it { should validate_presence_of(:kind) }
    it { should validate_numericality_of(:score).is_greater_than_or_equal_to(0) }
  end

  describe 'Enums' do
    it do
      should define_enum_for(:kind).
               with(multiple_choice: 0, multiple_response: 1, complete: 2,
                    fill_in_the_blank: 3, drag_drop: 4, dropdown_list: 5,
                    hot_spot: 6, spreadsheet: 7, open: 8)
    end
  end

  describe 'Concern' do
    it_behaves_like 'cbe_support'
  end

  describe 'Factory' do
    it { expect(cbe_question).to be_a Cbe::Question }
    it { expect(cbe_question).to be_valid }
  end
end
