# == Schema Information
#
# Table name: quiz_attempts
#
#  id                                :integer          not null, primary key
#  user_id                           :integer
#  quiz_question_id                  :integer
#  quiz_answer_id                    :integer
#  correct                           :boolean          default(FALSE), not null
#  course_module_element_user_log_id :integer
#  created_at                        :datetime
#  updated_at                        :datetime
#  score                             :integer          default(0)
#  answer_array                      :string(255)
#

require 'rails_helper'

describe QuizAttempt do

  # attr-accessible
  black_list = %w(id created_at updated_at score)
  QuizAttempt.column_names.each do |column_name|
    if black_list.include?(column_name)
      it { should_not allow_mass_assignment_of(column_name.to_sym) }
    else
      it { should allow_mass_assignment_of(column_name.to_sym) }
    end
  end

  # Constants
  #it { expect()QuizAttempt.const_defined?(:CONSTANT_NAME)).to eq(true) }

  # relationships
  it { should belong_to(:course_module_element_user_log) }
  it { should belong_to(:quiz_answer) }
  it { should belong_to(:quiz_question) }
  it { should belong_to(:user) }

  # validation
  it { should_not validate_presence_of(:user_id) }
  it { should validate_numericality_of(:user_id) }

  it { should validate_presence_of(:quiz_question_id) }
  it { should validate_numericality_of(:quiz_question_id) }

  it { should validate_presence_of(:quiz_answer_id) }
  it { should validate_numericality_of(:quiz_answer_id) }

  it { should validate_presence_of(:course_module_element_user_log_id).on(:update) }
  it { should validate_numericality_of(:course_module_element_user_log_id) }

  # callbacks
  it { should callback(:calculate_score).before(:create) }
  it { should callback(:check_dependencies).before(:destroy) }

  # scopes
  it { expect(QuizAttempt).to respond_to(:all_in_order) }

  # class methods

  # instance methods
  it { should respond_to(:destroyable?) }

end
