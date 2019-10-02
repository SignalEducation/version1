require 'rails_helper'

RSpec.describe Cbe::Answer, type: :model do
  let(:cbe_answer) { build(:cbe_answer, :with_question) }

  describe 'Should Respond' do
    it { should respond_to(:kind) }
    it { should respond_to(:content) }
    it { should respond_to(:cbe_question_id) }
    it { should respond_to(:created_at) }
    it { should respond_to(:updated_at) }
  end

  describe 'Associations' do
    it { should belong_to(:question) }
  end

  describe 'Validations' do
    it { should validate_presence_of(:kind) }
  end

  describe 'Enums' do
    it do
      should define_enum_for(:kind).
               with(multiple_choice: 0, multiple_response: 1, complete: 2,
                    fill_in_the_blank: 3, drag_drop: 4, dropdown_list: 5,
                    hot_spot: 6, spreadsheet: 7, open: 8)
    end
  end

  describe 'Factory' do
    it { expect(cbe_answer).to be_a Cbe::Answer }
    it { expect(cbe_answer).to be_valid }
  end
end
