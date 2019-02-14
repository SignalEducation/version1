# == Schema Information
#
# Table name: constructed_responses
#
#  id                       :integer          not null, primary key
#  course_module_element_id :integer
#  created_at               :datetime         not null
#  updated_at               :datetime         not null
#  time_allowed             :integer
#  destroyed_at             :datetime
#

require 'rails_helper'

describe ConstructedResponse do
  # relationships
  it { should belong_to(:course_module_element) }

  it { should have_one(:scenario) }

  # validation
  it { should validate_presence_of(:course_module_element_id).on(:update) }
  it { should validate_numericality_of(:course_module_element_id).on(:update) }

  # callbacks
  it { should callback(:check_dependencies).before(:destroy) }

  # scopes
  it { expect(ConstructedResponse).to respond_to(:all_in_order) }

  # class methods
  it { expect(ConstructedResponse).to respond_to(:constructed_response_nested_scenario_text_is_blank?) }

  # instance methods
  it { should respond_to(:destroyable?) }
  it { should respond_to(:add_an_empty_scenario) }


end
