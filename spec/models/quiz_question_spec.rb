# == Schema Information
#
# Table name: quiz_questions
#
#  id                            :integer          not null, primary key
#  course_module_element_quiz_id :integer
#  course_module_element_id      :integer
#  difficulty_level              :string(255)
#  solution_to_the_question      :text
#  hints                         :text
#  created_at                    :datetime
#  updated_at                    :datetime
#

require 'rails_helper'

describe QuizQuestion do

  # attr-accessible
  black_list = %w(id created_at updated_at)
  QuizQuestion.column_names.each do |column_name|
    if black_list.include?(column_name)
      it { should_not allow_mass_assignment_of(column_name.to_sym) }
    else
      it { should allow_mass_assignment_of(column_name.to_sym) }
    end
  end

  # Constants
  it { QuizQuestion.const_defined?(:DIFFICULTY_LEVELS) }

  # relationships
  it { should belong_to(:course_module_element_quiz) }
  it { should belong_to(:course_module_element) }
  it { should have_many(:quiz_attempts) }
  it { should have_many(:quiz_contents) }

  # validation
  it { should validate_presence_of(:course_module_element_quiz_id) }
  it { should validate_numericality_of(:course_module_element_quiz_id) }

  it { should validate_presence_of(:course_module_element_id) }
  it { should validate_numericality_of(:course_module_element_id) }

  it { should validate_presence_of(:difficulty_level) }

  it { should validate_presence_of(:solution_to_the_question) }

  it { should validate_presence_of(:hints) }

  # callbacks
  it { should callback(:check_dependencies).before(:destroy) }

  # scopes
  it { expect(QuizQuestion).to respond_to(:all_in_order) }

  # class methods

  # instance methods
  it { should respond_to(:destroyable?) }

end
