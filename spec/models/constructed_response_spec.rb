# frozen_string_literal: true

# == Schema Information
#
# Table name: constructed_responses
#
#  id             :integer          not null, primary key
#  course_step_id :integer
#  created_at     :datetime         not null
#  updated_at     :datetime         not null
#  time_allowed   :integer
#  destroyed_at   :datetime
#

require 'rails_helper'

describe ConstructedResponse, type: :model do
  let!(:course_step)          { create(:course_step) }
  let!(:constructed_response) { create(:constructed_response, course_step: course_step) }

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

  describe '#methods' do
    context '.constructed_response_nested_scenario_text_is_blank' do
      it 'return true to empty attributes' do
        attributes = {}

        expect(ConstructedResponse.constructed_response_nested_scenario_text_is_blank?(attributes)).to be(true)
      end

      it 'return false to filled text_content attributes' do
        attributes = { 'text_content' => 'asdf' }

        expect(ConstructedResponse.constructed_response_nested_scenario_text_is_blank?(attributes)).to be(false)
      end
    end

    describe '#destroyable?' do
      it 'always return true' do
        expect(constructed_response).to be_destroyable
      end
    end

    describe '#add_an_empty_scenario' do
      it 'should duplicate' do
        expect { constructed_response.add_an_empty_scenario }.to change { constructed_response.scenario.nil? }.from(true).to(false)
      end
    end

    describe '#check_dependencies' do
      it 'stubb destroyable to tru to cover method' do
        allow_any_instance_of(ConstructedResponse).to receive(:destroyable?).and_return(false)
        constructed_response.destroy

        expect(constructed_response.errors).not_to be_empty
      end
    end
  end
end
