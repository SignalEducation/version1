# == Schema Information
#
# Table name: cbes
#
#  id                :bigint           not null, primary key
#  name              :string
#  title             :string
#  content           :text
#  created_at        :datetime         not null
#  updated_at        :datetime         not null
#  course_id         :bigint
#  agreement_content :text
#  active            :boolean          default("true"), not null
#  score             :float
#
require 'rails_helper'

RSpec.describe Cbe, type: :model do
  let(:cbe) { build(:cbe) }

  describe 'Should Respond' do
    it { should respond_to(:name) }
    it { should respond_to(:title) }
    it { should respond_to(:content) }
    it { should respond_to(:course_id) }
    it { should respond_to(:agreement_content) }
    it { should respond_to(:score) }
    it { should respond_to(:created_at) }
    it { should respond_to(:updated_at) }
  end

  describe 'Associations' do
    it { should belong_to(:course) }
    it { should have_many(:sections) }
    it { should have_many(:introduction_pages) }
    it { should have_many(:questions).through(:sections) }
  end

  describe 'Validations' do
    it { should validate_presence_of(:name) }
    it { should validate_presence_of(:agreement_content) }
    it { should validate_presence_of(:course_id) }
  end

  describe 'scopes' do
    it { expect(Cbe).to respond_to(:all_in_order) }
  end

  describe 'Methods' do
    it { should respond_to(:duplicate) }
  end

  describe 'Factory' do
    it { expect(cbe).to be_a Cbe }
    it { expect(cbe).to be_valid }
  end
end
