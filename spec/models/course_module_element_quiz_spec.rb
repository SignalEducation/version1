# == Schema Information
#
# Table name: course_module_element_quizzes
#
#  id                                :integer          not null, primary key
#  course_module_element_id          :integer
#  time_limit_seconds                :integer
#  number_of_questions               :integer
#  question_selection_strategy       :string(255)
#  best_possible_score_first_attempt :integer
#  best_possible_score_retry         :integer
#  course_module_jumbo_quiz_id       :integer
#  created_at                        :datetime
#  updated_at                        :datetime
#

require 'rails_helper'

describe CourseModuleElementQuiz do

  # attr-accessible
  black_list = %w(id created_at updated_at question_selection_strategy
                 best_possible_score_first_attempt)
  CourseModuleElementQuiz.column_names.each do |column_name|
    if black_list.include?(column_name)
      it { should_not allow_mass_assignment_of(column_name.to_sym) }
    else
      it { should allow_mass_assignment_of(column_name.to_sym) }
    end
  end

  # Constants
  #it { expect()CourseModuleElementQuiz.const_defined?(:CONSTANT_NAME)).to eq(true) }

  # relationships
  it { should belong_to(:course_module_element) }
  it { should belong_to(:course_module_jumbo_quiz) }
  it { should have_many(:quiz_questions) }

  # validation
  it { should validate_presence_of(:course_module_element_id).on(:update) }
  xit { should validate_numericality_of(:course_module_element_id) }

  it { should validate_presence_of(:time_limit_seconds) }

  it { should validate_presence_of(:number_of_questions).on(:update) }
  xit { should validate_numericality_of(:number_of_questions) }

  it { should validate_presence_of(:best_possible_score_first_attempt).on(:update) }

  it { should validate_presence_of(:best_possible_score_retry).on(:update) }

  it { should validate_presence_of(:course_module_jumbo_quiz_id).on(:update) }
  xit { should validate_numericality_of(:course_module_jumbo_quiz_id) }

  # callbacks
  it { should callback(:check_dependencies).before(:destroy) }

  # scopes
  it { expect(CourseModuleElementQuiz).to respond_to(:all_in_order) }

  # class methods

  # instance methods
  it { should respond_to(:destroyable?) }


end
