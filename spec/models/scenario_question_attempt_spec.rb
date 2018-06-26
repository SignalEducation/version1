# == Schema Information
#
# Table name: scenario_question_attempts
#
#  id                                 :integer          not null, primary key
#  constructed_response_attempt_id    :integer
#  course_module_element_user_log_id  :integer
#  user_id                            :integer
#  constructed_response_id            :integer
#  scenario_question_id               :integer
#  status                             :string
#  flagged_for_review                 :boolean          default(FALSE)
#  original_scenario_question_text    :text
#  user_edited_scenario_question_text :text
#  created_at                         :datetime         not null
#  updated_at                         :datetime         not null
#

require 'rails_helper'

describe ScenarioQuestionAttempt do

  # attr-accessible
  black_list = %w(id created_at updated_at)
  ScenarioQuestionAttempt.column_names.each do |column_name|
    if black_list.include?(column_name)
      it { should_not allow_mass_assignment_of(column_name.to_sym) }
    else
      it { should allow_mass_assignment_of(column_name.to_sym) }
    end
  end

  # Constants
  #it { expect(ScenarioQuestionAttempt.const_defined?(:CONSTANT_NAME)).to eq(true) }

  # relationships
  it { should belong_to(:constructed_response_attempt) }
  it { should belong_to(:course_module_element_user_log) }
  it { should belong_to(:user) }
  it { should belong_to(:constructed_response) }
  it { should belong_to(:scenario_question) }

  # validation
  it { should validate_presence_of(:constructed_response_attempt_id) }
  it { should validate_numericality_of(:constructed_response_attempt_id) }

  it { should validate_presence_of(:course_module_element_user_log_id) }
  it { should validate_numericality_of(:course_module_element_user_log_id) }

  it { should validate_presence_of(:user_id) }
  it { should validate_numericality_of(:user_id) }

  it { should validate_presence_of(:constructed_response_id) }
  it { should validate_numericality_of(:constructed_response_id) }

  it { should validate_presence_of(:scenario_question_id) }
  it { should validate_numericality_of(:scenario_question_id) }

  it { should validate_presence_of(:status) }

  it { should validate_presence_of(:original_scenario_question_text) }

  it { should validate_presence_of(:user_edited_scenario_question_text) }

  # callbacks
  it { should callback(:check_dependencies).before(:destroy) }

  # scopes
  it { expect(ScenarioQuestionAttempt).to respond_to(:all_in_order) }

  # class methods

  # instance methods
  it { should respond_to(:destroyable?) }

  pending "Please review #{__FILE__}"

end
