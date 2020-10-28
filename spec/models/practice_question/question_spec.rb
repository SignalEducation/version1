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
end
