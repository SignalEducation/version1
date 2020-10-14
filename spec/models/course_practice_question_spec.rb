require 'rails_helper'
require 'concerns/archivable_spec.rb'

describe CoursePracticeQuestion do
  describe 'relationships' do
    it { should belong_to(:course_step) }
    it { should have_many(:questions) }
  end

  describe 'validations' do
    it { should validate_presence_of(:course_step_id).on(:update) }
    it { should validate_presence_of(:content) }
  end

  describe 'Enums' do
    it { should define_enum_for(:kind).with(standard: 0, exhibit: 1) }
  end

  describe 'Concern' do
    it_behaves_like 'archivable'
  end
end
