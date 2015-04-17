# == Schema Information
#
# Table name: quiz_questions
#
#  id                            :integer          not null, primary key
#  course_module_element_quiz_id :integer
#  course_module_element_id      :integer
#  difficulty_level              :string(255)
#  hints                         :text
#  created_at                    :datetime
#  updated_at                    :datetime
#  flash_quiz_id                 :integer
#

require 'rails_helper'

describe QuizQuestion do

  # attr-accessible
  black_list = %w(id created_at updated_at course_module_element_id)
  QuizQuestion.column_names.each do |column_name|
    if black_list.include?(column_name)
      it { should_not allow_mass_assignment_of(column_name.to_sym) }
    else
      it { should allow_mass_assignment_of(column_name.to_sym) }
    end
  end

  # Constants
  #it { expect()QuizQuestion.const_defined?(:CONSTANT_NAME)).to eq(true) }

  # relationships
  it { should belong_to(:course_module_element_quiz) }
  it { should belong_to(:course_module_element) }
  it { should belong_to(:flash_quiz) }
  it { should have_many(:quiz_attempts) }
  it { should have_many(:quiz_contents) }
  it { should have_many(:quiz_answers) }
  it { should have_many(:quiz_solutions) }

  # validation
  xit { should validate_numericality_of(:course_module_element_quiz_id) }

  it { should validate_presence_of(:course_module_element_id).on(:update) }
  xit { should validate_numericality_of(:course_module_element_id) }

  it { should validate_inclusion_of(:difficulty_level).in_array(ApplicationController::DIFFICULTY_LEVEL_NAMES).on(:update) }

  it { should allow_value(nil).for(:hints) }
  it { should ensure_length_of(:hints).is_at_most(65535) }

  # callbacks
  it { should callback(:set_course_module_element).before(:validation) }
  it { should callback(:check_dependencies).before(:destroy) }

  # scopes
  it { expect(QuizQuestion).to respond_to(:all_in_order) }

  # class methods

  # instance methods
  it { should respond_to(:complex_question?) }
  it { should respond_to(:destroyable?) }

end
