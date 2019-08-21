require 'rails_helper'

RSpec.describe Cbe::MultipleChoiceQuestion, type: :model do
  let(:cbe_multiple_choice_question) { build(:cbe_multiple_choice_question, :with_cbe_section) }

  describe 'Should Respond' do
    it { should respond_to(:name) }
    it { should respond_to(:description) }
    it { should respond_to(:label) }
    it { should respond_to(:order) }
    it { should respond_to(:question_1) }
    it { should respond_to(:question_2) }
    it { should respond_to(:question_3) }
    it { should respond_to(:question_4) }
    it { should respond_to(:question_4) }
    it { should respond_to(:is_correct_answer) }
    it { should respond_to(:created_at) }
    it { should respond_to(:updated_at) }
  end

  describe 'Associations' do
    it { should belong_to(:cbe_section) }
  end

  describe 'Factory' do
    it { expect(cbe_multiple_choice_question).to be_a Cbe::MultipleChoiceQuestion }
    it { expect(cbe_multiple_choice_question).to be_valid }
  end
end
