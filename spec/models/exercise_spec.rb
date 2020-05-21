# == Schema Information
#
# Table name: exercises
#
#  id                      :bigint           not null, primary key
#  product_id              :bigint
#  state                   :string
#  created_at              :datetime         not null
#  updated_at              :datetime         not null
#  user_id                 :bigint
#  corrector_id            :bigint
#  submission_file_name    :string
#  submission_content_type :string
#  submission_file_size    :bigint
#  submission_updated_at   :datetime
#  correction_file_name    :string
#  correction_content_type :string
#  correction_file_size    :bigint
#  correction_updated_at   :datetime
#  submitted_on            :datetime
#  corrected_on            :datetime
#  returned_on             :datetime
#  order_id                :bigint
#
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

  describe 'class methods' do
    describe '.parse_csv' do
      let(:test_file) { fixture_file_upload('/exercises/test_bulk_csv.csv', 'text/csv') }

      it 'parses a CSV file' do
        expect(CSV).to receive(:new).with(kind_of(String), hash_including(headers: true)).and_return([])

        Exercise.parse_csv(test_file.read)
      end

      it 'returns an array' do
        expect(Exercise.parse_csv(test_file.read)).to be_kind_of Array
      end
    end

    describe '.bulk_create' do
      let(:user) { create(:user) }
      let(:csv_data) { { 'user_id' => [user.id], 'email' => ['test@example.com'] } }

      it 'returns an array' do
        expect(Exercise.bulk_create(csv_data, 1)).to be_kind_of Array
      end

      it 'calls CsvBulkExerciseWorker' do
        expect(CsvBulkExerciseWorker).to receive(:perform_async).with(user.id, 1)

        Exercise.bulk_create(csv_data, 1)
      end
    end
  end
end
