# frozen_string_literal: true

# == Schema Information
#
# Table name: levels
#
#  id                           :bigint           not null, primary key
#  group_id                     :integer
#  name                         :string
#  name_url                     :string
#  active                       :boolean          default("false"), not null
#  highlight_colour             :string           default("#ef475d")
#  sorting_order                :integer
#  icon_label                   :string
#  created_at                   :datetime         not null
#  updated_at                   :datetime         not null
#  onboarding_course_subheading :text
#  onboarding_course_heading    :string
#
require 'rails_helper'

RSpec.describe Level, type: :model do

  let!(:level)                  { create(:level, active: true) }

  describe 'Should Respond' do
    it { should respond_to(:group_id) }
    it { should respond_to(:name) }
    it { should respond_to(:name_url) }
    it { should respond_to(:active) }
    it { should respond_to(:highlight_colour) }
    it { should respond_to(:sorting_order) }
    it { should respond_to(:icon_label) }
    it { should respond_to(:created_at) }
    it { should respond_to(:updated_at) }
    it { should respond_to(:onboarding_course_subheading) }
    it { should respond_to(:onboarding_course_heading) }
  end

  # relationships
  it { should belong_to(:group) }
  it { should have_many(:courses) }

  # validation
  it { should validate_presence_of(:name) }
  it { should validate_uniqueness_of(:name) }

  it { should validate_presence_of(:name_url) }
  it { should validate_uniqueness_of(:name_url) }

  it { should validate_presence_of(:onboarding_course_heading) }
  # callbacks

  # scopes
  it { expect(Group).to respond_to(:all_in_order) }
  it { expect(Group).to respond_to(:all_active) }

  # class methods

  # instance methods
  it { should respond_to(:destroyable?) }

  describe '#destroyable?' do
    context 'always return true' do
      it { expect(level).to be_destroyable }
    end
  end

  describe '.search' do
    context 'return should find level by name' do
      it { expect(Level.search(level.name.first(3))).to include(level) }
      it { expect(Level.search(level.name.last(2))).to include(level) }
    end

    context 'return should find level by description' do
      it { expect(Level.search(level.name_url.first(3))).to include(level) }
      it { expect(Level.search(level.name_url.last(2))).to include(level) }
    end

    context 'return should find level without any search' do
      it { expect(Level.search(nil)).to include(level) }
    end
  end
end
