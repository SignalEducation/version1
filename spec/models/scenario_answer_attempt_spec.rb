# == Schema Information
#
# Table name: scenario_answer_attempts
#
#  id                               :integer          not null, primary key
#  scenario_question_attempt_id     :integer
#  user_id                          :integer
#  scenario_answer_template_id      :integer
#  original_answer_template_text    :text
#  user_edited_answer_template_text :text
#  editor_type                      :string
#  created_at                       :datetime         not null
#  updated_at                       :datetime         not null
#  sorting_order                    :integer
#

require 'rails_helper'

describe ScenarioAnswerAttempt do
  # relationships
  it { should belong_to(:scenario_question_attempt) }
  it { should belong_to(:user) }
  it { should belong_to(:scenario_answer_template) }

  # validation
  it { should validate_presence_of(:scenario_question_attempt_id) }
  it { should validate_numericality_of(:scenario_question_attempt_id) }

  it { should validate_presence_of(:user_id) }
  it { should validate_numericality_of(:user_id) }

  it { should validate_presence_of(:scenario_answer_template_id) }
  it { should validate_numericality_of(:scenario_answer_template_id) }

  it { should validate_presence_of(:editor_type) }

  # callbacks
  it { should callback(:check_dependencies).before(:destroy) }

  # scopes
  it { expect(ScenarioAnswerAttempt).to respond_to(:all_in_order) }

  # class methods

  # instance methods
  it { should respond_to(:destroyable?) }

  it { should respond_to(:spreadsheet_editor?) }

  it { should respond_to(:text_editor?) }

end
