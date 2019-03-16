# == Schema Information
#
# Table name: course_module_element_quizzes
#
#  id                          :integer          not null, primary key
#  course_module_element_id    :integer
#  number_of_questions         :integer
#  question_selection_strategy :string
#  created_at                  :datetime
#  updated_at                  :datetime
#  destroyed_at                :datetime
#

require 'rails_helper'

describe CourseModuleElementQuiz do
  # Constants
  it { expect(CourseModuleElementQuiz.const_defined?(:STRATEGIES)).to eq(true) }

  # relationships
  it { should belong_to(:course_module_element) }
  it { should have_many(:quiz_questions) }

  # validation
  it { should validate_presence_of(:course_module_element_id).on(:update) }

  it { should validate_presence_of(:number_of_questions).on(:update) }

  it { should validate_inclusion_of(:question_selection_strategy).in_array(CourseModuleElementQuiz::STRATEGIES) }
  it { should validate_length_of(:question_selection_strategy).is_at_most(255) }

  # callbacks
  it { should callback(:check_dependencies).before(:destroy) }

  # scopes
  it { expect(CourseModuleElementQuiz).to respond_to(:all_in_order) }
  it { expect(CourseModuleElementQuiz).to respond_to(:all_destroyed) }

  # class methods

  # instance methods
  it { should respond_to(:enough_questions?) }
  it { should respond_to(:add_an_empty_question) }

  it { should respond_to(:all_ids_random) }
  it { should respond_to(:all_ids_ordered) }

  it { should respond_to(:destroyable?) }
  it { should respond_to(:destroyable_children) }


end
