require 'rails_helper'

RSpec.describe Category, type: :model do
  let(:category) { build(:category) }

  describe 'Should Respond' do
    it { should respond_to(:id) }
    it { should respond_to(:name) }
    it { should respond_to(:name_url) }
    it { should respond_to(:description) }
    it { should respond_to(:active) }
    it { should respond_to(:created_at) }
    it { should respond_to(:updated_at) }
  end

  describe 'Associations' do
    it { should have_many(:sub_categories) }
    it { should have_many(:groups) }
    it { should have_many(:exam_bodies).through(:groups) }
  end

  describe 'Validations' do
    it { should validate_presence_of(:name) }
    it { should validate_presence_of(:name_url) }
    it { should validate_inclusion_of(:active).in_array([true, false]) }
    it { should validate_uniqueness_of(:name_url) }
  end

  describe 'Factory' do
    it { expect(category).to be_a Category }
    it { expect(category).to be_valid }
  end
end
