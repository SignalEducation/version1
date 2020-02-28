# == Schema Information
#
# Table name: quiz_questions
#
#  id                            :integer          not null, primary key
#  course_module_element_quiz_id :integer
#  course_module_element_id      :integer
#  difficulty_level              :string(255)
#  created_at                    :datetime
#  updated_at                    :datetime
#  destroyed_at                  :datetime
#  subject_course_id             :integer
#  sorting_order                 :integer
#  custom_styles                 :boolean          default("false")
#

require 'rails_helper'

describe QuizQuestion do

  # relationships
  it { should belong_to(:subject_course) }
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

  # scopes
  it { expect(QuizQuestion).to respond_to(:all_in_order) }
  it { expect(QuizQuestion).to respond_to(:in_created_order) }
  it { expect(QuizQuestion).to respond_to(:all_destroyed) }

  # class methods

  # instance methods
  it { should respond_to(:destroyable?) }
  it { should respond_to(:destroyable_children) }

end
