# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Cbe::Resource, type: :model do
  let(:cbe_resource) { build(:cbe_resource) }

  it 'has a valid factory' do
    expect(build(:cbe_resource)).to be_valid
  end

  describe 'Should Respond' do
    it { should respond_to(:name) }
    it { should respond_to(:sorting_order) }
    it { should have_attached_file(:document) }
    it { should respond_to(:cbe_id) }
    it { should respond_to(:created_at) }
    it { should respond_to(:updated_at) }
  end

  describe 'Associations' do
    it { should belong_to(:cbe) }
  end

  describe 'Validations' do
    it { should validate_presence_of(:name) }
    it 'validates the presence of the CBE' do
      expect(build(:cbe_resource, cbe: nil)).not_to be_valid
    end
    it { should validate_attachment_presence(:document) }
    it { should validate_attachment_content_type(:document).allowing('application/pdf') }
  end

  describe 'Factory' do
    it { expect(cbe_resource).to be_a Cbe::Resource }
    it { expect(cbe_resource).to be_valid }
  end
end
