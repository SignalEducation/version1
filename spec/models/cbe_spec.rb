require 'rails_helper'

RSpec.describe Cbe, type: :model do
  let(:cbe) { build(:cbe, :with_subject_course) }

  describe 'Should Respond' do
    it { should respond_to(:name) }
    it { should respond_to(:title) }
    it { should respond_to(:description) }
    it { should respond_to(:exam_time) }
    it { should respond_to(:hard_time_limit) }
    it { should respond_to(:number_of_pauses_allowed) }
    it { should respond_to(:length_of_pauses) }
    it { should respond_to(:created_at) }
    it { should respond_to(:updated_at) }
  end

  describe 'Associations' do
    it { should belong_to(:subject_course) }
    it { should have_many(:sections) }
    it { should have_many(:questions).through(:sections) }
  end

  describe 'Validations' do
    it { should validate_presence_of(:name) }
    it { should validate_presence_of(:title) }
    it { should validate_presence_of(:description) }
    it { should validate_presence_of(:subject_course_id) }
  end

  describe 'Factory' do
    it { expect(cbe).to be_a Cbe }
    it { expect(cbe).to be_valid }
  end

  describe '#initialize_settings' do
    it 'initialize' do
      expect(cbe).to be_a_new(Cbe)

      expect { cbe.initialize_settings }.
        to  change { cbe.exam_time }.from(nil).to(120).
        and change { cbe.number_of_pauses_allowed }.from(nil).to(32).
        and change { cbe.length_of_pauses }.from(nil).to(15)

      expect(cbe).not_to be_a_new(Cbe)
    end
  end
end
