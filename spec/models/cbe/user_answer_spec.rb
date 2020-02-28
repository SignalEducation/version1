# == Schema Information
#
# Table name: cbe_user_answers
#
#  id                   :bigint           not null, primary key
#  content              :json
#  created_at           :datetime         not null
#  updated_at           :datetime         not null
#  cbe_answer_id        :bigint
#  cbe_user_question_id :bigint
#
require 'rails_helper'

RSpec.describe Cbe::UserAnswer, type: :model do
  let(:cbe_user_answer) { build(:cbe_user_answer) }

  describe 'Should Respond' do
    it { should respond_to(:content) }
    it { should respond_to(:cbe_user_question_id) }
    it { should respond_to(:cbe_answer_id) }
    it { should respond_to(:created_at) }
    it { should respond_to(:updated_at) }
  end

  describe 'Associations' do
    it { should belong_to(:question) }
  end

  describe 'Validations' do
    it { should validate_presence_of(:content) }
  end

  describe 'Factory' do
    it { expect(cbe_user_answer).to be_a Cbe::UserAnswer }
    it { expect(cbe_user_answer).to be_valid }
  end
end
