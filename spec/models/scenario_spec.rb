# frozen_string_literal: true

# == Schema Information
#
# Table name: scenarios
#
#  id                      :integer          not null, primary key
#  constructed_response_id :integer
#  sorting_order           :integer
#  text_content            :text
#  created_at              :datetime         not null
#  updated_at              :datetime         not null
#  destroyed_at            :datetime
#

require 'rails_helper'

describe Scenario do
  # relationships
  it { should belong_to(:constructed_response) }
  it { should have_many(:scenario_questions) }

  # validation
  it { should validate_presence_of(:constructed_response_id).on(:update) }
  it { should validate_numericality_of(:constructed_response_id).on(:update) }

  it { should validate_presence_of(:text_content).on(:update) }

  # callbacks
  it { should callback(:check_dependencies).before(:destroy) }

  # scopes
  it { expect(Scenario).to respond_to(:all_in_order) }

  # class methods
  it { expect(Scenario).to respond_to(:scenario_nested_question_is_blank?) }

  # instance methods
  it { should respond_to(:destroyable?) }
  it { should respond_to(:add_an_empty_scenario_question) }
end
