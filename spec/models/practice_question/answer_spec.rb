require 'rails_helper'

RSpec.describe PracticeQuestion::Answer, type: :model do
  let(:step)     { build(:course_step) }
  let(:question) { build(:course_practice_question, course_step: step) }
  let(:answer)   { build(:practice_question_answer, practice_question: question) }

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
    it { expect(answer).to be_a PracticeQuestion::Answer }
    it { expect(answer).to be_valid }
  end
end
