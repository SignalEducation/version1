# == Schema Information
#
# Table name: question_banks
#
#  id                          :integer          not null, primary key
#  user_id                     :integer
#  exam_level_id               :integer
#  easy_questions              :integer
#  medium_questions            :integer
#  hard_questions              :integer
#  question_selection_strategy :string
#  created_at                  :datetime         not null
#  updated_at                  :datetime         not null
#  exam_section_id             :integer
#  subject_course_id           :integer
#

require 'rails_helper'

describe QuestionBank do

  # attr-accessible
  black_list = %w(id created_at updated_at)
  QuestionBank.column_names.each do |column_name|
    if black_list.include?(column_name)
      it { should_not allow_mass_assignment_of(column_name.to_sym) }
    else
      it { should allow_mass_assignment_of(column_name.to_sym) }
    end
  end

  # Constants
  it { expect(QuestionBank.const_defined?(:STRATEGIES)).to eq(true) }

  # relationships
  it { should belong_to(:user) }
  it { should belong_to(:exam_level) }
  it { should have_many(:course_module_element_user_logs) }

  # validation
  it { should validate_presence_of(:user_id) }
  it { should validate_numericality_of(:user_id) }

  it { should_not validate_presence_of(:exam_level_id) }
  it { should validate_numericality_of(:exam_level_id) }

  it { should_not validate_presence_of(:exam_section_id) }
  it { should validate_numericality_of(:exam_section_id) }


  # callbacks
  it { should callback(:check_dependencies).before(:destroy) }

  # scopes
  it { expect(QuestionBank).to respond_to(:all_in_order) }

  # class methods

  # instance methods
  it { should respond_to(:destroyable?) }
  it { should respond_to(:number_of_questions) }

end
