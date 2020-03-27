# == Schema Information
#
# Table name: constructed_responses
#
#  id                       :integer          not null, primary key
#  course_step_id :integer
#  created_at               :datetime         not null
#  updated_at               :datetime         not null
#  time_allowed             :integer
#  destroyed_at             :datetime
#

require 'rails_helper'

describe ConstructedResponse do
  let!(:course_step) { create(:course_step) }
  let!(:constructed_response)  { create(:constructed_response, course_step: course_step) }

  describe 'relationships' do
    it { should belong_to(:course_step) }
    it { should have_one(:scenario) }
  end

  describe 'validations' do
    it { should validate_presence_of(:course_step_id).on(:update) }
    it { should validate_numericality_of(:course_step_id).on(:update) }
  end

  describe 'callbacks' do
    it { should callback(:check_dependencies).before(:destroy) }
  end

  describe 'scopes' do
    it { expect(ConstructedResponse).to respond_to(:all_in_order) }
  end

  describe 'class methods' do
    it { expect(ConstructedResponse).to respond_to(:constructed_response_nested_scenario_text_is_blank?) }
  end

  describe 'instance methods' do
    it { should respond_to(:destroyable?) }
    it { should respond_to(:add_an_empty_scenario) }
    it { should respond_to(:duplicate) }
  end
end
