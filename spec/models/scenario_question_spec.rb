# == Schema Information
#
# Table name: scenario_questions
#
#  id            :integer          not null, primary key
#  scenario_id   :integer
#  sorting_order :integer
#  text_content  :text
#  created_at    :datetime         not null
#  updated_at    :datetime         not null
#  destroyed_at  :datetime
#

require 'rails_helper'

describe ScenarioQuestion do
  # relationships
  it { should belong_to(:scenario) }
  it { should have_many(:scenario_answer_templates) }
  it { should have_many(:scenario_question_attempts) }

  # validation
  it { should validate_presence_of(:scenario_id).on(:update) }
  it { should validate_numericality_of(:scenario_id).on(:update) }

  it { should validate_presence_of(:text_content) }

  # callbacks
  it { should callback(:check_dependencies).before(:destroy) }

  # scopes
  it { expect(ScenarioQuestion).to respond_to(:all_in_order) }

  # class methods
  it { expect(ScenarioQuestion).to respond_to(:question_nested_answer_template_is_blank?) }

  # instance methods
  it { should respond_to(:destroyable?) }


end
