# == Schema Information
#
# Table name: quiz_questions
#
#  id                            :integer          not null, primary key
#  course_module_element_quiz_id :integer
#  course_module_element_id      :integer
#  difficulty_level              :string
#  created_at                    :datetime
#  updated_at                    :datetime
#  destroyed_at                  :datetime
#  subject_course_id             :integer
#  sorting_order                 :integer
#  custom_styles                 :boolean          default(FALSE)
#

require 'rails_helper'

describe QuizQuestion do

  # attr-accessible
  black_list = %w(id created_at updated_at course_module_element_id destroyed_at)
  QuizQuestion.column_names.each do |column_name|
    if black_list.include?(column_name)
      it { should_not allow_mass_assignment_of(column_name.to_sym) }
    else
      it { should allow_mass_assignment_of(column_name.to_sym) }
    end
  end

  # Constants

  # relationships
  it { should belong_to(:course_module_element) }
  it { should belong_to(:course_module_element_quiz) }
  it { should have_many(:quiz_attempts) }
  it { should have_many(:quiz_answers) }
  it { should have_many(:quiz_contents) }
  it { should have_many(:quiz_solutions) }

  # validation

  it { should validate_presence_of(:course_module_element_id).on(:update) }

  # callbacks
  it { should callback(:check_dependencies).before(:destroy) }
  it { should callback(:set_course_module_element).before(:validation) }
  it { should callback(:set_subject_course_id).before(:save) }

  # scopes
  it { expect(QuizQuestion).to respond_to(:all_in_order) }
  it { expect(QuizQuestion).to respond_to(:all_destroyed) }

  # class methods

  # instance methods
  it { should respond_to(:destroyable?) }
  it { should respond_to(:destroyable_children) }

end
