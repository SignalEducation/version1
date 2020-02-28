# == Schema Information
#
# Table name: scenario_question_attempts
#
#  id                                 :integer          not null, primary key
#  constructed_response_attempt_id    :integer
#  user_id                            :integer
#  scenario_question_id               :integer
#  status                             :string
#  flagged_for_review                 :boolean          default("false")
#  original_scenario_question_text    :text
#  user_edited_scenario_question_text :text
#  created_at                         :datetime         not null
#  updated_at                         :datetime         not null
#  sorting_order                      :integer
#

require 'rails_helper'

describe ScenarioQuestionAttempt do

  # relationships
  it { should belong_to(:scenario_question) }
  it { should belong_to(:user) }
  it { should belong_to(:constructed_response_attempt) }
  it { should have_many(:scenario_answer_attempts) }

  # validation
  it { should validate_presence_of(:constructed_response_attempt_id) }
  it { should validate_numericality_of(:constructed_response_attempt_id) }

  it { should validate_presence_of(:user_id) }
  it { should validate_numericality_of(:user_id) }

  it { should validate_presence_of(:scenario_question_id) }
  it { should validate_numericality_of(:scenario_question_id) }

  it { should validate_presence_of(:status) }
  it { should validate_inclusion_of(:status).in_array(ScenarioQuestionAttempt::STATUS) }

  it { should validate_presence_of(:original_scenario_question_text) }

  it { should validate_presence_of(:user_edited_scenario_question_text) }

  # callbacks
  it { should callback(:check_dependencies).before(:destroy) }

  # scopes
  it { expect(ScenarioQuestionAttempt).to respond_to(:all_in_order) }

  # class methods

  # instance methods
  it { should respond_to(:destroyable?) }

end
