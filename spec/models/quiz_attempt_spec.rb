# == Schema Information
#
# Table name: quiz_attempts
#
#  id                                :integer          not null, primary key
#  user_id                           :integer
#  quiz_question_id                  :integer
#  quiz_answer_id                    :integer
#  correct                           :boolean          default("false"), not null
#  course_step_log_id :integer
#  created_at                        :datetime
#  updated_at                        :datetime
#  score                             :integer          default("0")
#  answer_array                      :string(255)
#

require 'rails_helper'

describe QuizAttempt do

  # relationships
  it { should belong_to(:course_step_log) }
  it { should belong_to(:quiz_answer) }
  it { should belong_to(:quiz_question) }
  it { should belong_to(:user) }

  # validation
  it { should validate_presence_of(:quiz_question_id) }

  it { should validate_presence_of(:quiz_answer_id) }

  it { should validate_presence_of(:course_step_log_id).on(:update) }

  it { should validate_presence_of(:answer_array).on(:update) }

  it { should_not validate_presence_of(:user_id) }

  # callbacks
  it { should callback(:calculate_score).after(:create) }
  it { should callback(:check_dependencies).before(:destroy) }

  # scopes
  it { expect(QuizAttempt).to respond_to(:all_in_order) }
  it { expect(QuizAttempt).to respond_to(:all_correct) }
  it { expect(QuizAttempt).to respond_to(:all_incorrect) }

  # class methods

  # instance methods
  it { should respond_to(:answers) }
  it { should respond_to(:destroyable?) }

end
