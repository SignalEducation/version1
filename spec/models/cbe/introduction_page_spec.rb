# == Schema Information
#
# Table name: cbe_introduction_pages
#
#  id            :bigint           not null, primary key
#  sorting_order :integer
#  content       :text
#  title         :string
#  created_at    :datetime         not null
#  updated_at    :datetime         not null
#  cbe_id        :bigint
#  kind          :integer          default("0"), not null
#
require 'rails_helper'

RSpec.describe Cbe::IntroductionPage, type: :model do
  let(:cbe_introduction_page) { build(:cbe_introduction_page, :with_cbe) }

  describe 'Should Respond' do
    it { should respond_to(:sorting_order) }
    it { should respond_to(:title) }
    it { should respond_to(:content) }
    it { should respond_to(:cbe_id) }
    it { should respond_to(:created_at) }
    it { should respond_to(:updated_at) }
  end

  describe 'Associations' do
    it { should belong_to(:cbe) }
  end

  describe 'Validations' do
    it { should validate_presence_of(:title) }
    it { should validate_presence_of(:content) }
    it { should validate_presence_of(:cbe_id) }
  end

  describe 'Factory' do
    it { expect(cbe_introduction_page).to be_a Cbe::IntroductionPage }
    it { expect(cbe_introduction_page).to be_valid }
  end
end
