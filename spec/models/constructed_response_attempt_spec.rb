# == Schema Information
#
# Table name: constructed_response_attempts
#
#  id                                :integer          not null, primary key
#  constructed_response_id           :integer
#  scenario_id                       :integer
#  course_module_element_id          :integer
#  course_module_element_user_log_id :integer
#  user_id                           :integer
#  original_scenario_text_content    :text
#  user_edited_scenario_text_content :text
#  status                            :string
#  flagged_for_review                :boolean          default("false")
#  time_in_seconds                   :integer
#  created_at                        :datetime         not null
#  updated_at                        :datetime         not null
#  guid                              :string
#  scratch_pad_text                  :text
#

require 'rails_helper'

describe ConstructedResponseAttempt do
  subject { FactoryBot.build(:constructed_response_attempt) }

  describe 'constants' do
    it { expect(ConstructedResponseAttempt.const_defined?(:STATUS)).to eq(true) }
  end

  describe 'relationships' do
    it { should belong_to(:constructed_response) }
    it { should belong_to(:scenario) }
    it { should belong_to(:course_module_element) }
    it { should belong_to(:course_module_element_user_log) }
    it { should belong_to(:user) }
    it { should have_many(:scenario_question_attempts) }
  end

  describe 'validations' do
    it { should validate_presence_of(:constructed_response_id) }
    it { should validate_numericality_of(:constructed_response_id) }
    it { should validate_presence_of(:scenario_id) }
    it { should validate_numericality_of(:scenario_id) }
    # TODO - Why does this validation not exist in model
    xit { should validate_presence_of(:course_module_element_id) }
    xit { should validate_numericality_of(:course_module_element_id) }
    it { should validate_presence_of(:course_module_element_user_log_id).on(:update)  }
    it { should validate_numericality_of(:course_module_element_user_log_id).on(:update)  }
    it { should validate_presence_of(:user_id) }
    it { should validate_numericality_of(:user_id) }
    it { should validate_presence_of(:original_scenario_text_content) }
    it { should validate_presence_of(:user_edited_scenario_text_content) }
    it { should validate_inclusion_of(:status).in_array(ConstructedResponseAttempt::STATUS) }
    it { should validate_presence_of(:guid) }
    it { should validate_uniqueness_of(:guid) }
    it { should validate_length_of(:guid).is_at_most(255) }
  end

  describe 'callbacks' do
    it { should callback(:check_dependencies).before(:destroy) }
  end

  describe 'scopes' do
    it { expect(ConstructedResponseAttempt).to respond_to(:all_in_order) }
  end

  describe 'instance methods' do
    it { should respond_to(:destroyable?) }
  end


end
