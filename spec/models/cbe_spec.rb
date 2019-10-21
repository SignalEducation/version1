require 'rails_helper'

RSpec.describe Cbe, type: :model do
  let(:cbe) { build(:cbe) }

  describe 'Should Respond' do
    it { should respond_to(:name) }
    it { should respond_to(:title) }
    it { should respond_to(:content) }
    it { should respond_to(:subject_course_id) }
    it { should respond_to(:agreement_content) }
    it { should respond_to(:score) }
    it { should respond_to(:created_at) }
    it { should respond_to(:updated_at) }
  end


  describe 'Associations' do
    it { should belong_to(:subject_course) }
    it { should have_many(:sections) }
    it { should have_many(:introduction_pages) }
    it { should have_many(:questions).through(:sections) }
  end

  describe 'Validations' do
    it { should validate_presence_of(:name) }
    xit { should validate_presence_of(:title) }
    xit { should validate_presence_of(:score) }
    xit { should validate_presence_of(:content) }
    it { should validate_presence_of(:agreement_content) }
    it { should validate_presence_of(:subject_course_id) }
  end

  describe 'Factory' do
    it { expect(cbe).to be_a Cbe }
    it { expect(cbe).to be_valid }
  end
end
