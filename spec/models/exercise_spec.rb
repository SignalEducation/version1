require 'rails_helper'

RSpec.describe Exercise, type: :model do
  let(:exercise) { build(:exercise) }

  describe 'Should Respond' do
    it { should respond_to(:product_id) }
    it { should respond_to(:state) }
    it { should respond_to(:user_id) }
    it { should respond_to(:corrector_id) }
    it { should respond_to(:submission_file_name) }
    it { should respond_to(:submission_content_type) }
    it { should respond_to(:submission_file_size) }
    it { should respond_to(:submission_updated_at) }
    it { should respond_to(:correction_file_name) }
    it { should respond_to(:correction_content_type) }
    it { should respond_to(:correction_file_size) }
    it { should respond_to(:correction_updated_at) }
    it { should respond_to(:submitted_on) }
    it { should respond_to(:corrected_on) }
    it { should respond_to(:returned_on) }
    it { should respond_to(:order_id) }
    it { should respond_to(:created_at) }
    it { should respond_to(:updated_at) }
  end

  describe 'Associations' do
    it { should belong_to(:product) }
    it { should belong_to(:order) }
    it { should belong_to(:user) }
    it { should belong_to(:corrector) }
    it { should have_one(:cbe_user_log) }
    it { should have_attached_file(:submission) }
    it { should have_attached_file(:correction) }
  end

  describe 'Validations' do
    it { should validate_attachment_content_type(:submission).allowing('application/pdf') }
    it { should validate_attachment_content_type(:correction).allowing('application/pdf') }
  end

  describe 'scopes' do
    it { expect(Exercise).to respond_to(:state) }
    it { expect(Exercise).to respond_to(:product) }
    it { expect(Exercise).to respond_to(:search) }
  end

  describe 'Factory' do
    it { expect(exercise).to be_a Exercise }
    it { expect(exercise).to be_valid }
  end

  describe '.search_scopes' do
    it 'has the correct search_scopes' do
      expect(Exercise.search_scopes).to eq(
        [:state, :product, :corrector, :search]
      )
    end
  end
end
