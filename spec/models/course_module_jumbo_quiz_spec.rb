# == Schema Information
#
# Table name: course_module_jumbo_quizzes
#
#  id                              :integer          not null, primary key
#  course_module_id                :integer
#  name                            :string(255)
#  minimum_question_count_per_quiz :integer
#  maximum_question_count_per_quiz :integer
#  total_number_of_questions       :integer
#  created_at                      :datetime
#  updated_at                      :datetime
#  name_url                        :string(255)
#

require 'rails_helper'

describe CourseModuleJumboQuiz do

  # attr-accessible
  black_list = %w(id created_at updated_at)
  CourseModuleJumboQuiz.column_names.each do |column_name|
    if black_list.include?(column_name)
      it { should_not allow_mass_assignment_of(column_name.to_sym) }
    else
      it { should allow_mass_assignment_of(column_name.to_sym) }
    end
  end

  # Constants
  #it { expect()CourseModuleJumboQuiz.const_defined?(:CONSTANT_NAME)).to eq(true) }

  # relationships
  it { should belong_to(:course_module) }
  it { should have_many(:course_module_element_quizzes) }

  # validation
  it { should validate_presence_of(:course_module_id) }
  it { should validate_numericality_of(:course_module_id) }

  it { should validate_presence_of(:name) }

  it { should validate_presence_of(:name_url) }

  it { should validate_presence_of(:minimum_question_count_per_quiz) }
  it { should validate_numericality_of(:minimum_question_count_per_quiz) }

  it { should validate_presence_of(:maximum_question_count_per_quiz) }
  it { should validate_numericality_of(:maximum_question_count_per_quiz) }

  it { should validate_presence_of(:total_number_of_questions) }
  it { should validate_numericality_of(:total_number_of_questions) }

  # callbacks
  it { should callback(:sanitize_name_url).before(:save) }
  it { should callback(:check_dependencies).before(:destroy) }

  # scopes
  it { expect(CourseModuleJumboQuiz).to respond_to(:all_in_order) }

  # class methods

  # instance methods
  it { should respond_to(:destroyable?) }
  it { should respond_to(:name_url) }

end
