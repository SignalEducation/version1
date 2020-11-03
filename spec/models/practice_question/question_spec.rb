# frozen_string_literal: true

# == Schema Information
#
# Table name: practice_question_questions
#
#  id                          :bigint           not null, primary key
#  kind                        :integer
#  content                     :json
#  solution                    :json
#  sorting_order               :integer
#  course_practice_question_id :bigint
#  created_at                  :datetime         not null
#  updated_at                  :datetime         not null
#  description                 :text
#
require 'rails_helper'

RSpec.describe PracticeQuestion::Question, type: :model do
  let(:step)              { build(:course_step) }
  let(:practice_question) { build(:course_practice_question, course_step: step) }
  let(:question)          { build(:practice_question_questions, practice_question: practice_question) }

  describe 'Should Respond' do
    it { should respond_to(:kind) }
    it { should respond_to(:content) }
    it { should respond_to(:course_practice_question_id) }
    it { should respond_to(:created_at) }
    it { should respond_to(:updated_at) }
  end

  describe 'Associations' do
    it { should belong_to(:practice_question) }
  end

  describe 'Enums' do
    it { should define_enum_for(:kind).with(open: 0, spreadsheet: 1) }
  end

  describe 'Factory' do
    it { expect(question).to be_a PracticeQuestion::Question }
    it { expect(question).to be_valid }
  end

  context 'Methods' do
    describe '.parse_spreadsheet' do
      let(:spreadsheet_question) { build(:practice_question_questions, :spreadsheet_question, practice_question: practice_question) }

      before { spreadsheet_question.parse_spreadsheet }

      it 'parse json' do
        expect(spreadsheet_question.content).to be_a_kind_of(Hash)
        expect(spreadsheet_question.solution).to be_a_kind_of(Hash)
      end
    end

    describe '.parsed_content' do
      let(:spreadsheet_question) { build(:practice_question_questions, :spreadsheet_question, practice_question: practice_question) }

      before { spreadsheet_question.parsed_content }

      it 'parse json content' do
        expect(spreadsheet_question.content).to be_a_kind_of(String)
        expect(spreadsheet_question.solution).to be_a_kind_of(String)
      end
    end

    describe '.parsed_solution' do
      let(:spreadsheet_question) { build(:practice_question_questions, :spreadsheet_question, practice_question: practice_question) }

      before { spreadsheet_question.parsed_solution }

      it 'parse json solution' do
        expect(spreadsheet_question.content).to be_a_kind_of(String)
        expect(spreadsheet_question.solution).to be_a_kind_of(String)
      end
    end
  end
end
