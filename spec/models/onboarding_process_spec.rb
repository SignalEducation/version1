# == Schema Information
#
# Table name: onboarding_processes
#
#  id            :bigint           not null, primary key
#  user_id       :integer
#  course_log_id :integer
#  active        :boolean          default("true"), not null
#  created_at    :datetime         not null
#  updated_at    :datetime         not null
#
require 'rails_helper'

describe OnboardingProcess do

  describe 'Should Respond' do
    it { should respond_to(:user_id) }
    it { should respond_to(:course_log_id) }
    it { should respond_to(:active) }
    it { should respond_to(:created_at) }
    it { should respond_to(:updated_at) }
  end

  describe 'Constants' do
    it { expect(Message.const_defined?(:STATES)).to eq(true) }
  end

  describe 'Associations' do
    it { should belong_to(:user) }
    it { should belong_to(:course_log) }
  end

  describe 'Validations' do
    it { should validate_presence_of(:user_id) }
    it { should validate_presence_of(:course_log_id) }
  end

  describe 'callbacks' do
    it { should callback(:create_workers).after(:create) }
  end

  describe 'instance methods' do
    it { should respond_to(:content_remaining?) }
    it { should respond_to(:next_step) }
    it { should respond_to(:send_email) }
  end

end
