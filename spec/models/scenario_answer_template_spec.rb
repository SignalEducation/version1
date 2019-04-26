# == Schema Information
#
# Table name: scenario_answer_templates
#
#  id                         :integer          not null, primary key
#  scenario_question_id       :integer
#  sorting_order              :integer
#  editor_type                :string
#  created_at                 :datetime         not null
#  updated_at                 :datetime         not null
#  destroyed_at               :datetime
#  text_editor_content        :text
#  spreadsheet_editor_content :text
#

require 'rails_helper'

describe ScenarioAnswerTemplate do

  # Constants
  it { expect(ScenarioAnswerTemplate.const_defined?(:FORMAT_TYPES)).to eq(true) }

  # relationships
  it { should belong_to(:scenario_question) }
  it { should have_many(:scenario_answer_attempts) }

  # validation
  it { should validate_presence_of(:scenario_question_id).on(:update) }
  it { should validate_numericality_of(:scenario_question_id).on(:update) }

  it { should validate_presence_of(:editor_type) }
  it { should validate_inclusion_of(:editor_type).in_array(ScenarioAnswerTemplate::FORMAT_TYPES) }

  # callbacks
  it { should callback(:check_dependencies).before(:destroy) }

  # scopes
  it { expect(ScenarioAnswerTemplate).to respond_to(:all_in_order) }

  # class methods

  # instance methods
  it { should respond_to(:destroyable?) }
  it { should respond_to(:spreadsheet_editor?) }
  it { should respond_to(:text_editor?) }


end
