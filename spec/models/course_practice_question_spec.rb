# == Schema Information
#
# Table name: course_practice_questions
#
#  id                    :bigint           not null, primary key
#  name                  :string
#  content               :text
#  kind                  :integer
#  estimated_time        :integer
#  course_step_id        :bigint
#  destroyed_at          :datetime
#  created_at            :datetime         not null
#  updated_at            :datetime         not null
#  document_file_name    :string
#  document_content_type :string
#  document_file_size    :bigint
#  document_updated_at   :datetime
#
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

  describe 'instance methods' do
    it { should respond_to(:duplicate) }
  end

  describe 'Concern' do
    it_behaves_like 'archivable'
  end
end
